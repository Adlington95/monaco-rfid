import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/qualifying/practice_instructions_page.dart';
import 'package:frontend/pages/qualifying/qualifying_start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState with ChangeNotifier {
  GameState({
    required this.isEmulator,
    required String serverUrl,
    required this.restPort,
    required this.websocketPort,
    required this.circuitName,
    required this.circuitLength,
    required this.practiceLaps,
    required this.qualifyingLaps,
    required this.eventName,
    required this.finishPageDuration,
    required this.raceLaps,
    required this.raceLights,
  }) : _serverUrl = serverUrl;

  GameState._({
    required this.isEmulator,
    String? serverUrl,
    String? restPort,
    String? websocketPort,
    String? circuitName,
    double? circuitLength,
    int? practiceLaps,
    int? qualifyingLaps,
    String? eventName,
    int? finishPageDuration,
    int? raceLaps,
    int? raceLights,
  })  : _serverUrl = serverUrl ?? defaultServerUrl,
        restPort = restPort ?? defaultRestPort,
        websocketPort = websocketPort ?? defaultWebsocketPort,
        circuitName = circuitName ?? defaultCircuitName,
        circuitLength = circuitLength ?? defaultCircuitLength,
        practiceLaps = practiceLaps ?? defaultPracticeLaps,
        qualifyingLaps = qualifyingLaps ?? defaultQualifyingLaps,
        eventName = eventName ?? defaultEventName,
        finishPageDuration = finishPageDuration ?? defaultFinishPageDuration,
        raceLaps = raceLaps ?? defaultRaceLaps,
        raceLights = raceLights ?? defaultRaceLights;

  String _serverUrl;
  String get serverUrl => _serverUrl;
  set serverUrl(String value) {
    _serverUrl = value;
    notifyListeners();
  }

  final bool isEmulator;

  String restPort;
  String websocketPort;
  String circuitName;
  String eventName;
  double circuitLength;
  int practiceLaps;
  int qualifyingLaps;
  int finishPageDuration;
  int raceLaps;
  int raceLights;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    notifyListeners();
    _isLoading = value;
  }

  User? _loggedInUser;
  User? get loggedInUser => _loggedInUser;
  set loggedInUser(User? value) {
    _loggedInUser = value;
    if (value != null) {
      notifyListeners();
      changePage();
    }
  }

  List<User> racers = [];

  void addRacer(User racer) {
    racers.add(racer);
    notifyListeners();
  }

  Future<void> changePage() async {
    if (loggedInUser != null) {
      await Future<void>.delayed(const Duration(seconds: 5));
      if (loggedInUser != null &&
          MyApp.navigatorKey.currentContext != null &&
          ModalRoute.of(MyApp.navigatorKey.currentContext!)?.settings.name != PracticeInstructionsPage.name) {
        await router.pushReplacement(QualifyingStartPage.name);
      }
    }
  }

  static Future<GameState> loadFromPreferences({required bool isEmulator}) async {
    final prefs = await SharedPreferences.getInstance();

    return GameState._(
      isEmulator: isEmulator,
      serverUrl: prefs.getString(serverUrlKey),
      restPort: prefs.getString(restPortKey),
      websocketPort: prefs.getString(websocketPortKey),
      circuitName: prefs.getString(circuitNameKey),
      circuitLength: prefs.getDouble(circuitLengthKey),
      practiceLaps: prefs.getInt(practiceLapsKey),
      qualifyingLaps: prefs.getInt(qualifyingLapsKey),
      finishPageDuration: prefs.getInt(finishPageDurationKey),
      eventName: prefs.getString(eventNameKey),
      raceLaps: prefs.getInt(raceLapsKey),
    );
  }

  // static Future<GameState> loadFromJson() async {
  //   try {
  //     final result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['json'],
  //     );
  //     if (result == null) return GameState._(isEmulator: isEmulator);
  //     final file = File(result.files.single.path!);
  //     final content = await file.readAsString();
  //     final json = jsonDecode(content) as Map<String, dynamic>;

  //     return GameState._(
  //       serverUrl: json[serverUrlKey] as String?,
  //       restPort: json[restPortKey] as String?,
  //       websocketPort: json[websocketPortKey] as String?,
  //       circuitName: json[circuitNameKey] as String?,
  //       circuitLength: json[circuitLengthKey] as double?,
  //       practiceLaps: json[practiceLapsKey] as int?,
  //       qualifyingLaps: json[qualifyingLapsKey] as int?,
  //     );
  //   } catch (e) {
  //     return GameState._();
  //   }
  // }

  // Future<void> applyFromJson() async {
  //   isLoading = true;
  //   final other = await loadFromJson();

  //   serverUrl = other.serverUrl;
  //   restPort = other.restPort;
  //   websocketPort = other.websocketPort;
  //   circuitName = other.circuitName;
  //   circuitLength = other.circuitLength;
  //   practiceLaps = other.practiceLaps;
  //   qualifyingLaps = other.qualifyingLaps;

  //   isLoading = false;
  // }

  Future<void> saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(serverUrlKey, serverUrl);
    await prefs.setString(restPortKey, restPort);
    await prefs.setString(websocketPortKey, websocketPort);
    await prefs.setString(circuitNameKey, circuitName);
    await prefs.setDouble(circuitLengthKey, circuitLength);
    await prefs.setInt(practiceLapsKey, practiceLaps);
    await prefs.setInt(qualifyingLapsKey, qualifyingLaps);
    await prefs.setInt(finishPageDurationKey, finishPageDuration);
    await prefs.setString(eventNameKey, eventName);
    await prefs.setInt(raceLapsKey, raceLaps);
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

  Uri get restUrl => Uri.parse('http://$serverUrl:$restPort');
  Uri get wsUrl => Uri.parse('ws://$serverUrl:$websocketPort');

  void clear() {
    _loggedInUser = null;
    racers.clear();

    notifyListeners();
  }
}
