import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
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

  final Uri uri = Uri.parse('ws://$defaultServerUrl:$defaultWebsocketPort');

  String _message = '';
  String get message => _message;

  List<double> lapTimes = [];

  void addMessage(String message) {
    if (message.contains('connected')) {
      router.pushReplacement(PracticeInstructionsPage.name);
      return;
    } else {
      lapTimes = message.replaceAll(RegExp(r'[\[\]]'), '').split(',').map((element) {
        return double.tryParse(element)!;
      }).toList();
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

  Future<void> sendLapTime(double lapTime) async {
    await restState.postFastestLap(lapTime);
    await restState.fetchDriverStandings();
    await router.pushReplacement(FinishPage.name);
  }

  int get practiceLapsRemaining => (3 - lapTimes.length).clamp(1, 3);

  double get averageSpeed => 10;

  DateTime startTime = DateTime(2024, 11, 8, 11, 42, 40);

  double get fastestLap =>
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
      _channel = WebSocketChannel.connect(uri);
      await _channel?.ready;
      debugPrint('Connected to: $uri');
      _subscription = _channel!.stream.listen((data) {
        try {
          // TODO: type this
          _message = data.toString();

          debugPrint('Received: $_message');
          notifyListeners();
        } catch (e) {
          debugPrint('Error parsing message: $data');
        }
      });
    } catch (e) {
      debugPrint('Error connecting to: $uri');
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
