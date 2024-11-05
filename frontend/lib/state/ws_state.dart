import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketState with ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final Uri uri = Uri.parse('ws://192.168.0.1:8080');

  String _message = '';

  String get message => _message;

  final List<String> _messages = [];

  List<String> get messages => _messages;

  void connect() {
    _channel = WebSocketChannel.connect(uri);
    print('Connected to: $uri');
    _subscription = _channel!.stream.listen((data) {
      _message = data;
      messages.add(data);
      print('Received: $_message');
      notifyListeners();
    });
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
