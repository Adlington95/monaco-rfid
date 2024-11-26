import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/finish_page.dart';
import 'package:frontend/pages/practice_coutdown_page.dart';
import 'package:frontend/pages/practice_instructions_page.dart';
import 'package:frontend/pages/qualifying_page.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketState with ChangeNotifier {
  WebSocketState(this.restState);

  final RestState restState;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  List<int> lapTimes = [];
  String carId = '';

  bool get connected => _channel != null;

  void addMessage(String message) {
    if (message.contains('Car scanned')) {
      try {
        final obj = jsonDecode(message);
        // ignore: avoid_dynamic_calls
        carId = obj['carId'] as String;
      } catch (e) {
        debugPrint('Error parsing message: $message');
      }

      if (restState.gameState.loggedInUser != null && restState.gameState.loggedInUser!.previousAttempts != 0) {
        router.pushReplacement(PracticeInstructionsPage.name);
      } else {
        router.pushReplacement(PracticeCountdownPage.name);
      }

      //TODO: Here add redirect to other instruction page

      return;
    } else {
      try {
        final obj = jsonDecode(message) as Map<String, dynamic>;
        lapTimes = (obj.entries.first.value as List).map((e) => e as int).toList();
      } catch (e) {
        debugPrint('Error parsing message: $message');
      }
    }
    if (practiceLapsRemaining > 0) {
      router.pushReplacement(PracticeCountdownPage.name);
    } else if (lapTimes.length == restState.gameState.practiceLaps) {
      router.pushReplacement(QualifyingPage.name);
    } else if (lapTimes.length >= restState.gameState.practiceLaps + restState.gameState.qualifyingLaps) {
      sendLapTime();
    }

    notifyListeners();
  }

  int get averageLapTime {
    if (lapTimes.isEmpty || lapTimes.length < restState.gameState.practiceLaps) {
      return 0;
    }
    final x = lapTimes.sublist(restState.gameState.practiceLaps).reduce((value, element) => value + element) ~/
        (lapTimes.length - restState.gameState.practiceLaps);
    return x;
  }

  Future<void> sendLapTime() async {
    unawaited(router.pushReplacement(FinishPage.name));
    await restState.postLap(fastestLap, overallTime, carId);
    await restState.fetchDriverStandings();
  }

  int get practiceLapsRemaining => restState.gameState.practiceLaps - lapTimes.length;

  double get averageSpeed {
    if (lapTimes.isEmpty) {
      return 0;
    }
    return restState.gameState.circuitLength / lapTimes.last;
  }

  DateTime? _startTime;

  DateTime get startTime => _startTime ??= DateTime.now();

  set startTime(DateTime? value) {
    _startTime = value;
    notifyListeners();
  }

  int get fastestLap => lapTimes.length <= restState.gameState.practiceLaps
      ? 0
      : lapTimes
          .sublist(restState.gameState.practiceLaps)
          .reduce((value, element) => value < element ? value : element);

  int get overallTime => lapTimes.length <= restState.gameState.practiceLaps
      ? 0
      : lapTimes.sublist(restState.gameState.practiceLaps).reduce((value, element) => value + element);

  String lapTime(int index) {
    if (lapTimes.length > (restState.gameState.practiceLaps - 1) + index) {
      return lapTimes[index + restState.gameState.practiceLaps - 1].toStringAsFixed(3);
    } else {
      return '';
    }
  }

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(restState.gameState.wsUrl);
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

  void sendMessage(String message) {
    if (_channel != null) {
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
  }

  @override
  void dispose() {
    disconnect();
    clearData();
    super.dispose();
  }
}
