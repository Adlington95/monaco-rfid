import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: constant_identifier_names
enum RaceMode { QUALIFYING, RACE }

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
    required this.scannedThingName,
    required String rfidReaderUrl,
    required this.raceMode,
  })  : _rfidReaderUrl = rfidReaderUrl,
        _serverUrl = serverUrl;

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
    String? scannedThingName,
    String? rfidReaderUrl,
    RaceMode? raceMode,
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
        raceLights = raceLights ?? defaultRaceLights,
        scannedThingName = scannedThingName ?? defaultScannedThingName,
        _rfidReaderUrl = rfidReaderUrl ?? defaultRFIDReaderUrl,
        raceMode = raceMode ?? (defaultRaceMode == 'QUALIFYING' ? RaceMode.QUALIFYING : RaceMode.RACE);

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
  String scannedThingName;
  double circuitLength;
  int practiceLaps;
  int qualifyingLaps;
  int finishPageDuration;
  int raceLaps;
  int raceLights;
  String _rfidReaderUrl;
  String get rfidReaderUrl => _rfidReaderUrl;
  set rfidReaderUrl(String value) {
    _rfidReaderUrl = value;
    http.post(
      Uri.parse('$restUrl/setRfidUrl'),
      body: jsonEncode({'ip': value}),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 2));
  }

  RaceMode raceMode;

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
    }
  }

  List<User> racers = [];

  void addRacer(User racer) {
    racers.add(racer);
    notifyListeners();
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
      raceLights: prefs.getInt(raceLightsKey),
      scannedThingName: prefs.getString(scannedThingNameKey),
      rfidReaderUrl: prefs.getString(rfidReaderUrlKey),
      raceMode: prefs.getString(raceModeKey) == 'QUALIFYING' ? RaceMode.QUALIFYING : RaceMode.RACE,
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
    await prefs.setInt(raceLightsKey, raceLights);
    await prefs.setString(scannedThingNameKey, scannedThingName);
    await prefs.setString(rfidReaderUrlKey, rfidReaderUrl);
    await prefs.setString(raceModeKey, raceMode == RaceMode.QUALIFYING ? 'QUALIFYING' : 'RACE');
  }

  // Future<void> saveToJson() async {
  //   final json = {
  //     serverUrlKey: serverUrl,
  //     restPortKey: restPort,
  //     websocketPortKey: websocketPort,
  //     circuitNameKey: circuitName,
  //     circuitLengthKey: circuitLength,
  //     practiceLapsKey: practiceLaps,
  //     qualifyingLapsKey: qualifyingLaps,
  //   };

  //   final result = await FilePicker.platform.saveFile(
  //     type: FileType.custom,
  //     allowedExtensions: ['json'],
  //     fileName: 'game_settings.json',
  //     initialDirectory: '/storage/emulated/0/Download',
  //     dialogTitle: 'Save game settings',
  //   );
  //   if (result == null) return;
  //   final file = File(result);
  //   await file.writeAsString(jsonEncode(json));
  // }

  Uri get restUrl => Uri.parse('http://$serverUrl:$restPort');
  Uri get wsUrl => Uri.parse('ws://$serverUrl:$websocketPort');

  void clear() {
    _loggedInUser = null;
    racers.clear();

    notifyListeners();
  }

  void sendProperties() {
    http.post(
      Uri.parse('$restUrl/setRfidUrl'),
      body: jsonEncode({'ip': rfidReaderUrl}),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 2));
  }
}
