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

  void addMessage(String message) {
    if (message.contains('connected')) {
      router.go(PracticeInstructionsPage.name);
      return;
    } else {
      lapTimes = message.replaceAll(RegExp(r'[\[\]]'), '').split(',').map((element) {
        return double.tryParse(element)!;
      }).toList();
    }

    if (lapTimes.length == 1) {
      router.go(PracticeCountdownPage.name);
    } else if (lapTimes.length == 3) {
      router.go(QualifyingPage.name);
    } else if (lapTimes.length == 13) {
      router.go(LeaderBoardsPage.name);
    }

    notifyListeners();
  }

  int get practiceLapsRemaining => (3 - lapTimes.length).clamp(1, 3);

  String lapTime(int index) {
    if (lapTimes.length > 2 + index) {
      return lapTimes[index + 2].toStringAsFixed(3);
    } else {
      return '';
    }
  }

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
  }

  @override
  void dispose() {
    disconnect();
    clearData();
    super.dispose();
  }
}
