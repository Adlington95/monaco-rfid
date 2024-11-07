import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterfrontend/constants.dart';
import 'package:flutterfrontend/main.dart';
import 'package:flutterfrontend/pages/leaderboards.dart';
import 'package:flutterfrontend/pages/practice_coutdown.dart';
import 'package:flutterfrontend/pages/practice_instructions.dart';
import 'package:flutterfrontend/pages/qualifying.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketState with ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final Uri uri = Uri.parse('ws://$serverUrl:$websocketPort');

  String _message = '';

  String get message => _message;

  List<double> lapTimes = [];
  List<double> practiceLapTimes = [];

  void addMessage(String message) {
    if (message.contains('connected')) {
      router.go(PracticeInstructionsPage.name);
      return;
    }

    final double? lapTime = double.tryParse(message);

    if (lapTime != null && practiceLapTimes.length < 3) {
      practiceLapTimes.add(lapTime);
    } else if (lapTime != null && lapTimes.length < 10) {
      lapTimes.add(lapTime);
    }

    if (practiceLapTimes.isEmpty && lapTime == null) {
    } else if (practiceLapTimes.length == 1) {
      router.go(PracticeCountdownPage.name);
    } else if (practiceLapTimes.length == 3) {
      router.go(QualifyingPage.name);
    } else if (lapTimes.length == 10) {
      router.go(LeaderBoardsPage.name);
    }

    notifyListeners();
  }

  int get practiceLapsRemaining => 3 - practiceLapTimes.length;

  void connect() {
    _channel = WebSocketChannel.connect(uri);
    debugPrint('Connected to: $uri');
    _subscription = _channel!.stream.listen((data) {
      _message = data;

      debugPrint('Received: $_message');
      notifyListeners();
    });
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
    practiceLapTimes = [];
  }

  @override
  void dispose() {
    disconnect();
    clearData();
    super.dispose();
  }
}
