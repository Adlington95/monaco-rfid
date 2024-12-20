import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/qualifying/practice_coutdown_page.dart';
import 'package:frontend/pages/qualifying/practice_instructions_page.dart';
import 'package:frontend/pages/qualifying/qualifying_finish_page.dart';
import 'package:frontend/pages/qualifying/qualifying_page.dart';
import 'package:frontend/pages/race/race_finish_page.dart';
import 'package:frontend/pages/race/race_instructions_page.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketState with ChangeNotifier {
  WebSocketState(this.restState);

  final RestState restState;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  List<int> lapTimes = [];
  Map<String, List<int>> raceLapTimes = {};
  String carId = '';
  User? raceWinner;

  Map<String, String> raceCarIds = {};

  List<String> invalidatedLaps = [];

  int get winningIndex => restState.gameState.racers.indexOf(raceWinner!);

  int get maxLaps => restState.status == Status.RACE
      ? restState.gameState.settings.raceLaps
      : restState.gameState.settings.qualifyingLaps;

  bool get connected => _channel != null;

  void addMessage(String message) {
    if (message.contains('jump')) {
      //jump start
      final obj = jsonDecode(message);
      // ignore: avoid_dynamic_calls
      final carId = obj['carId'] as String;
      invalidatedLaps.add(carId);
    } else if (message.contains('Car scanned')) {
      try {
        final obj = jsonDecode(message);
        // ignore: avoid_dynamic_calls
        final scannedCarId = obj['carId'] as String;
        if (restState.status != Status.RACE) {
          carId = scannedCarId;
        } else {
          if (raceCarIds.isEmpty) {
            raceCarIds[restState.gameState.racers.first.employeeId] = scannedCarId;
          } else {
            raceCarIds[restState.gameState.racers.last.employeeId] = scannedCarId;
            router.go(RaceInstructionsPage.name);
          }
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error parsing message: $message');
      }
      if (restState.status != Status.RACE && restState.gameState.loggedInUser != null) {
        if (restState.gameState.loggedInUser!.previousAttempts == 0) {
          router.pushReplacement(PracticeInstructionsPage.name);
        } else {
          router.pushReplacement(PracticeCountdownPage.name);
        }
      }

      return;
    } else {
      try {
        final obj = jsonDecode(message) as Map<String, dynamic>;
        if (restState.status != Status.RACE) {
          lapTimes = (obj.entries.first.value as List).map((e) => e as int).toList();
        } else {
          for (final element in obj.entries) {
            final carId = element.key;
            if (raceCarIds.entries.any((element) => element.value == carId)) {
              final lapTimes = (element.value as List).map((element) => element as int);
              raceLapTimes[carId] = lapTimes.toList();
            }
          }
          if (raceWinner == null) {
            final finishers =
                raceLapTimes.entries.where((element) => element.value.length > restState.gameState.settings.raceLaps);

            if (finishers.isNotEmpty) {
              final String winingCarId;

              if (finishers.length == 1) {
                winingCarId = finishers.first.key;
              } else {
                final p1Times = finishers.first.value
                    .getRange(1, restState.gameState.settings.raceLaps)
                    .reduce((combined, element) => combined + element);
                final p2Times = finishers.last.value
                    .getRange(1, restState.gameState.settings.raceLaps)
                    .reduce((combined, element) => combined + element);
                if (p1Times < p2Times) {
                  winingCarId = finishers.first.key;
                } else {
                  winingCarId = finishers.last.key;
                }
              }
              final userId = getUserIdFromCarId(winingCarId);
              raceWinner = restState.gameState.racers.firstWhereOrNull((element) => element.employeeId == userId);
            }
          }
        }
      } catch (e) {
        debugPrint('Error parsing message: $message');
      }
    }

    if (restState.status != Status.RACE) {
      if (practiceLapsRemaining > 0) {
        router.pushReplacement(PracticeCountdownPage.name);
      } else if (lapTimes.length == restState.gameState.settings.practiceLaps) {
        router.pushReplacement(QualifyingPage.name);
      } else if (lapTimes.length >=
          restState.gameState.settings.practiceLaps + restState.gameState.settings.qualifyingLaps) {
        sendLapTime();
      }
    } else if (raceWinner != null) {
      restState.reset();
      router.pushReplacement(RaceFinishPage.name);
    }

    notifyListeners();
  }

  String getUserIdFromCarId(String carId) {
    return raceCarIds.entries.firstWhere((element) => element.value == carId).key;
  }

  String? getUserIdFromIndex(int index) {
    if (index - 1 >= restState.gameState.racers.length) {
      return null;
    }
    return restState.gameState.racers[index - 1].id;
  }

  String getCarIdFromIndex(int index) {
    return raceCarIds.entries.toList()[index - 1].value;
  }

  List<int>? getLapTimesFromIndex(int index) {
    final userId = getUserIdFromIndex(index);
    if (userId == null) {
      return null;
    }
    return getLapTimes(userId);
  }

  List<int>? getLapTimes(String carId) {
    return raceLapTimes[carId];
  }

  bool isInvalidated(int index) {
    final carId = getCarIdFromIndex(index);

    return invalidatedLaps.contains(carId);
  }

  int get averageLapTime {
    if (lapTimes.isEmpty || lapTimes.length < restState.gameState.settings.practiceLaps) {
      return 0;
    }
    final x = lapTimes.sublist(restState.gameState.settings.practiceLaps).reduce((value, element) => value + element) ~/
        (lapTimes.length - restState.gameState.settings.practiceLaps);
    return x;
  }

  Future<void> sendLapTime() async {
    unawaited(router.pushReplacement(QualifyingFinishPage.name));
    if (fastestLap == null) {
      return;
    }
    await restState.postLap(fastestLap!, overallTime, carId);
    await restState.fetchDriverStandings();
  }

  int get practiceLapsRemaining => restState.gameState.settings.practiceLaps - lapTimes.length;

  String get practiceLapsRemainingString =>
      practiceLapsRemaining.clamp(1, restState.gameState.settings.practiceLaps).toString();

  double get averageSpeed {
    if (lapTimes.isEmpty) {
      return 0;
    }
    return restState.gameState.settings.circuitLength / lapTimes.last;
  }

  DateTime? _startTime;

  DateTime get startTime => _startTime ??= DateTime.now();

  set startTime(DateTime? value) {
    _startTime = value;
    notifyListeners();
  }

  int? get fastestLap => lapTimes.length <= restState.gameState.settings.practiceLaps
      ? null
      : lapTimes
          .sublist(restState.gameState.settings.practiceLaps)
          .reduce((value, element) => value < element ? value : element);

  int get overallTime => lapTimes.length <= restState.gameState.settings.practiceLaps
      ? 0
      : lapTimes.sublist(restState.gameState.settings.practiceLaps).reduce((value, element) => value + element);

  int get currentLap =>
      restState.status == Status.RACE ? 0 : lapTimes.length - restState.gameState.settings.practiceLaps;

  int getCurrentLapFromIndex(int index) {
    final carId = getCarIdFromIndex(index);
    final lapTimes = getLapTimes(carId);
    if (lapTimes == null || lapTimes.isEmpty) {
      return 0;
    }
    return lapTimes.length;
  }

  double getAverageSpeedFromIndex(int index) {
    final carId = getCarIdFromIndex(index);
    final lapTimes = getLapTimes(carId);
    if (lapTimes == null || lapTimes.isEmpty || lapTimes.length == 1) {
      return 0;
    }
    return restState.gameState.settings.circuitLength / lapTimes.last;
  }

  int get currentLapTime {
    if (lapTimes.isEmpty) {
      return 0;
    }
    return lapTimes.last;
  }

  int get totalLaps => restState.status == Status.RACE
      ? restState.gameState.settings.raceLaps
      : restState.gameState.settings.qualifyingLaps;

  String qualifyingLapTime(int lap) {
    if (lapTimes.length > (restState.gameState.settings.practiceLaps - 1) + lap) {
      return lapTimes[lap + restState.gameState.settings.practiceLaps - 1].toStringAsFixed(3);
    } else {
      return '';
    }
  }

  String raceLapTime(int lap, int index) {
    final carId = getCarIdFromIndex(index);
    final lapTimes = getLapTimes(carId);
    if (lapTimes == null || lapTimes.length <= lap) {
      return '';
    }
    return lapTimes[lap].toStringAsFixed(3);
  }

  int getFastestCurrantLap([int? index]) {
    if (index != null) {
      final carId = getCarIdFromIndex(index);
      final lapTimes = getLapTimes(carId);
      if (lapTimes == null || lapTimes.isEmpty) {
        return 0;
      }
      return lapTimes.reduce((value, element) => value < element ? value : element);
    } else if (restState.status == Status.RACE) {
      return raceLapTimes.entries
          .expand((element) => element.value)
          .reduce((value, element) => value < element ? value : element);
    } else {
      if (lapTimes.isEmpty || lapTimes.length < restState.gameState.settings.practiceLaps + 1) {
        return 100000;
      }
      return lapTimes
          .slice(restState.gameState.settings.practiceLaps)
          .reduce((value, element) => value < element ? value : element);
    }
  }

  int getFastestUserLap() {
    final baseLine = getFastestCurrantLap();
    final userLap = restState.gameState.loggedInUser?.previousFastestLap ?? 0;
    if (userLap != 0 && userLap < baseLine) {
      return userLap;
    }
    return baseLine;
  }

  int getFastestLapFromIndex(int index) {
    final carId = getCarIdFromIndex(index);
    final lapTimes = getLapTimes(carId);
    if (lapTimes == null || lapTimes.isEmpty || lapTimes.length == 1) {
      return 0;
    }
    return lapTimes.reduce((value, element) => value < element ? value : element);
  }

  Color? getLapColor(String time, int lap, [int? index]) {
    if (time == getFastestCurrantLap(index).toStringAsFixed(3) && index != null ||
        time == getFastestUserLap().toStringAsFixed(3) && index == null) {
      return Colors.purple;
    } else if (index == null && double.tryParse(time) != null && double.parse(time).toInt() == fastestLap) {
      return Colors.green;
    } else if (index != null && isInvalidated(index) && lap == 1) {
      return Colors.red;
    }
    return null;
  }

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(restState.gameState.settings.wsUrl);
      await _channel?.ready;
      debugPrint('Connected to: $restState.gameState.wsUrl');
      _subscription = _channel!.stream.listen(
        (data) {
          try {
            debugPrint('Received: $data');
            addMessage(data.toString());
            notifyListeners();
          } catch (e) {
            debugPrint('Error parsing message: $data');
          }
        },
        onDone: () {
          clear();
          if (lapTimes.length < 13) {
            Fluttertoast.showToast(msg: 'Connection lost');
            router.go('/');
          }
        },
        onError: (obj) {
          clear();

          if (lapTimes.length < 13) {
            Fluttertoast.showToast(msg: 'Connection lost');
            router.go('/');
          }
        },
      );
    } catch (e) {
      debugPrint('Error connecting to: $restState.gameState.wsUrl');
    }
  }

  void fakeToggleJumpStart(int index) {
    final carId = getCarIdFromIndex(index);
    if (invalidatedLaps.contains(carId)) {
      invalidatedLaps.remove(carId);
    } else {
      invalidatedLaps.add(carId);
    }

    notifyListeners();
  }

  void fakeLapTime([int? index]) {
    final fakeLapTime = (5000 + (10000 - 5000) * (DateTime.now().millisecondsSinceEpoch % 1000) ~/ 1000) + 20000;
    // final fakeLapTime = 20;
    if (index != null) {
      final carId = getCarIdFromIndex(index);
      if (raceLapTimes[carId] == null) {
        raceLapTimes[carId] = [];
      } else {
        raceLapTimes[carId]!.add(fakeLapTime);
        addMessage(jsonEncode(raceLapTimes));
      }
    } else {
      final newLaptimes = lapTimes..add(fakeLapTime);

      addMessage('{"lapTimes" : ${jsonEncode(newLaptimes)}}');
    }
  }

  void sendMessage(String message) {
    if (_channel != null) {
      debugPrint('Sending message: $message');
      _channel!.sink.add(message);
    }
  }

  void clear() {
    disconnect();
    clearData();
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void clearData() {
    lapTimes = [];
    raceLapTimes = {};
    carId = '';
    raceWinner = null;
    raceCarIds = {};
    _startTime = null;
  }

  @override
  void dispose() {
    disconnect();
    clearData();
    super.dispose();
  }
}
