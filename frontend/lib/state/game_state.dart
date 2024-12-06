import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: constant_identifier_names
enum RaceMode { QUALIFYING, RACE }

class GameState with ChangeNotifier {
  GameState({required this.isEmulator, required GameSettings settings}) : _settings = settings;

  GameSettings _settings;
  GameSettings get settings => _settings;
  set settings(GameSettings value) {
    _settings = value;
    notifyListeners();
  }

  final bool isEmulator;

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

  void clear() {
    _loggedInUser = null;
    racers.clear();

    notifyListeners();
  }

  void sendProperties() {
    http.post(
      Uri.parse('${settings.restUrl}/setRfidUrl'),
      body: jsonEncode({'ip': settings.rfidReaderUrl}),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 2));
  }

  Future<void> writeJson(GameSettings settings) async {
    try {
      final result = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(utf8.encode(jsonEncode(settings.toObject))),
        fileName: 'settings.json',
      );

      if (result == null) return;

      unawaited(Fluttertoast.showToast(msg: 'Settings saved to $result'));
    } catch (e) {
      debugPrint(e.toString());
      unawaited(Fluttertoast.showToast(msg: 'Failed to write file'));
    }
  }
}

extension on String? {
  bool get imageExists => File(this ?? '').existsSync();
}

class GameSettings extends Equatable {
  const GameSettings({
    required this.serverUrl,
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
    required this.rfidReaderUrl,
    required this.raceMode,
    required this.backgroundImage,
  });

  GameSettings.fromObj(Map<String, dynamic> json)
      : this(
          serverUrl: json[serverUrlKey] as String? ?? defaultServerUrl,
          restPort: json[restPortKey] as String? ?? defaultRestPort,
          websocketPort: json[websocketPortKey] as String? ?? defaultWebsocketPort,
          circuitName: json[circuitNameKey] as String? ?? defaultCircuitName,
          circuitLength: (json[circuitLengthKey] as num?)?.toDouble() ?? defaultCircuitLength,
          practiceLaps: json[practiceLapsKey] as int? ?? defaultPracticeLaps,
          qualifyingLaps: json[qualifyingLapsKey] as int? ?? defaultQualifyingLaps,
          eventName: json[eventNameKey] as String? ?? defaultEventName,
          finishPageDuration: json[finishPageDurationKey] as int? ?? defaultFinishPageDuration,
          raceLaps: json[raceLapsKey] as int? ?? defaultRaceLaps,
          raceLights: json[raceLightsKey] as int? ?? defaultRaceLights,
          scannedThingName: json[scannedThingNameKey] as String? ?? defaultScannedThingName,
          rfidReaderUrl: json[rfidReaderUrlKey] as String? ?? defaultRFIDReaderUrl,
          raceMode: json[raceModeKey] as String? ?? defaultRaceMode,
          backgroundImage:
              ((json[backgroundImageKey] as String?).imageExists) ? (json[backgroundImageKey] as String) : '',
        );

  final String serverUrl;
  final String restPort;
  final String websocketPort;
  final String circuitName;
  final double circuitLength;
  final int practiceLaps;
  final int qualifyingLaps;
  final String eventName;
  final int finishPageDuration;
  final int raceLaps;
  final int raceLights;
  final String scannedThingName;
  final String rfidReaderUrl;
  final String raceMode; // TODO: Integrate this
  final String backgroundImage;

  Uri get restUrl => Uri.parse('http://$serverUrl:$restPort');
  Uri get wsUrl => Uri.parse('ws://$serverUrl:$websocketPort');

  static Future<GameSettings> fromSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonDecode(prefs.getString('prefs') ?? '{}') as Map<String, dynamic>;
    return GameSettings.fromObj(json);
  }

  static Future<GameSettings?> fromJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      try {
        final content = await File(result.files.single.path!).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final settings = GameSettings.fromObj(json);
        unawaited(Fluttertoast.showToast(msg: 'Settings loaded from file'));
        return settings;
      } catch (e) {
        debugPrint(e.toString());
        unawaited(Fluttertoast.showToast(msg: 'Failed to read file'));
      }
    } else {
      unawaited(Fluttertoast.showToast(msg: 'No file selected'));
    }
    return null;
  }

  Future<void> toSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prefs', jsonEncode(toObject));
  }

  Map<String, dynamic> get toObject => {
        serverUrlKey: serverUrl,
        restPortKey: restPort,
        websocketPortKey: websocketPort,
        circuitNameKey: circuitName,
        circuitLengthKey: circuitLength,
        practiceLapsKey: practiceLaps,
        qualifyingLapsKey: qualifyingLaps,
        eventNameKey: eventName,
        finishPageDurationKey: finishPageDuration,
        raceLapsKey: raceLaps,
        raceLightsKey: raceLights,
        scannedThingNameKey: scannedThingName,
        rfidReaderUrlKey: rfidReaderUrl,
        raceModeKey: raceMode,
        backgroundImageKey: backgroundImage,
      };

  @override
  List<Object?> get props => toObject.values.toList();

  GameSettings copyWith({
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
    String? raceMode,
    String? backgroundImage,
  }) {
    return GameSettings(
      serverUrl: serverUrl ?? this.serverUrl,
      restPort: restPort ?? this.restPort,
      websocketPort: websocketPort ?? this.websocketPort,
      circuitName: circuitName ?? this.circuitName,
      circuitLength: circuitLength ?? this.circuitLength,
      practiceLaps: practiceLaps ?? this.practiceLaps,
      qualifyingLaps: qualifyingLaps ?? this.qualifyingLaps,
      eventName: eventName ?? this.eventName,
      finishPageDuration: finishPageDuration ?? this.finishPageDuration,
      raceLaps: raceLaps ?? this.raceLaps,
      raceLights: raceLights ?? this.raceLights,
      scannedThingName: scannedThingName ?? this.scannedThingName,
      rfidReaderUrl: rfidReaderUrl ?? this.rfidReaderUrl,
      raceMode: raceMode ?? this.raceMode,
      backgroundImage: backgroundImage ?? this.backgroundImage,
    );
  }
}
