import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState with ChangeNotifier {
  GameState({
    required this.serverUrl,
    required this.restPort,
    required this.websocketPort,
    required this.circuitName,
    required this.circuitLength,
    required this.practiceLaps,
    required this.qualifyingLaps,
    required this.eventName,
  });

  GameState._({
    String? serverUrl,
    String? restPort,
    String? websocketPort,
    String? circuitName,
    double? circuitLength,
    int? practiceLaps,
    int? qualifyingLaps,
    String? eventName,
  })  : serverUrl = serverUrl ?? defaultServerUrl,
        restPort = restPort ?? defaultRestPort,
        websocketPort = websocketPort ?? defaultWebsocketPort,
        circuitName = circuitName ?? defaultCircuitName,
        circuitLength = circuitLength ?? defaultCircuitLength,
        practiceLaps = practiceLaps ?? defaultPracticeLaps,
        qualifyingLaps = qualifyingLaps ?? defaultQualifyingLaps,
        eventName = eventName ?? defaultEventName;

  String serverUrl;
  String restPort;
  String websocketPort;
  String circuitName;
  String eventName;
  double circuitLength;
  int practiceLaps;
  int qualifyingLaps;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    notifyListeners();
    _isLoading = value;
  }

  static Future<GameState> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    return GameState._(
      serverUrl: prefs.getString(serverUrlKey),
      restPort: prefs.getString(restPortKey),
      websocketPort: prefs.getString(websocketPortKey),
      circuitName: prefs.getString(circuitNameKey),
      circuitLength: prefs.getDouble(circuitLengthKey),
      practiceLaps: prefs.getInt(practiceLapsKey),
      qualifyingLaps: prefs.getInt(qualifyingLapsKey),
    );
  }

  static Future<GameState> loadFromJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null) return GameState._();
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      return GameState._(
        serverUrl: json[serverUrlKey] as String?,
        restPort: json[restPortKey] as String?,
        websocketPort: json[websocketPortKey] as String?,
        circuitName: json[circuitNameKey] as String?,
        circuitLength: json[circuitLengthKey] as double?,
        practiceLaps: json[practiceLapsKey] as int?,
        qualifyingLaps: json[qualifyingLapsKey] as int?,
      );
    } catch (e) {
      return GameState._();
    }
  }

  Future<void> applyFromJson() async {
    isLoading = true;
    final other = await loadFromJson();

    serverUrl = other.serverUrl;
    restPort = other.restPort;
    websocketPort = other.websocketPort;
    circuitName = other.circuitName;
    circuitLength = other.circuitLength;
    practiceLaps = other.practiceLaps;
    qualifyingLaps = other.qualifyingLaps;

    isLoading = false;
  }

  Future<void> saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(serverUrlKey, serverUrl);
    await prefs.setString(restPortKey, restPort);
    await prefs.setString(websocketPortKey, websocketPort);
    await prefs.setString(circuitNameKey, circuitName);
    await prefs.setDouble(circuitLengthKey, circuitLength);
    await prefs.setInt(practiceLapsKey, practiceLaps);
    await prefs.setInt(qualifyingLapsKey, qualifyingLaps);
  }

  Future<void> saveToJson() async {
    final json = {
      serverUrlKey: serverUrl,
      restPortKey: restPort,
      websocketPortKey: websocketPort,
      circuitNameKey: circuitName,
      circuitLengthKey: circuitLength,
      practiceLapsKey: practiceLaps,
      qualifyingLapsKey: qualifyingLaps,
    };

    final result = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
      fileName: 'game_settings.json',
      initialDirectory: '/storage/emulated/0/Download',
      dialogTitle: 'Save game settings',
    );
    if (result == null) return;
    final file = File(result);
    await file.writeAsString(jsonEncode(json));
  }

  String get restUrl => 'http://$defaultServerUrl:$defaultRestPort';
  String get wsUrl => 'ws://$defaultServerUrl:$defaultWebsocketPort';
}
