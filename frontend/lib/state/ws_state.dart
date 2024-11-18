import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/finish.dart';
import 'package:frontend/pages/practice_coutdown.dart';
import 'package:frontend/pages/practice_instructions.dart';
import 'package:frontend/pages/qualifying.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketState with ChangeNotifier {
  WebSocketState(this.restState);

  final RestState restState;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  // final Uri uri = restState.gameState.wsUrl;

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
      router.pushReplacement(PracticeInstructionsPage.name);
      return;
    } else {
      try {
        final obj = jsonDecode(message);

        // ignore: avoid_dynamic_calls
        final lapTimesJson = obj['lapTimes'] as List<dynamic>;
        final newLapTimes = <int>[];
        for (final lapTime in lapTimesJson) {
          newLapTimes.add(lapTime as int);
        }
        // ignore: avoid_dynamic_calls
        lapTimes = newLapTimes;
      } catch (e) {
        debugPrint('Error parsing message: $message');
      }
    }

    if (lapTimes.length == 1) {
      router.pushReplacement(PracticeCountdownPage.name);
    } else if (lapTimes.length == 3) {
      router.pushReplacement(QualifyingPage.name);
    } else if (lapTimes.length == 13) {
      sendLapTime(fastestLap);
    }

    notifyListeners();
  }

  Future<void> sendLapTime(int lapTime) async {
    await restState.postFastestLap(lapTime, carId);
    await restState.fetchDriverStandings();
    await router.pushReplacement(FinishPage.name);
  }

  int get practiceLapsRemaining => (3 - lapTimes.length).clamp(1, 3);

  double get averageSpeed => 10;

  DateTime startTime = DateTime(2024, 11, 8, 11, 42, 40);

  int get fastestLap =>
      lapTimes.length < 4 ? 0 : lapTimes.sublist(3).reduce((value, element) => value < element ? value : element);

  String lapTime(int index) {
    if (lapTimes.length > 2 + index) {
      return lapTimes[index + 2].toStringAsFixed(3);
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
