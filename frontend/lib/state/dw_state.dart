import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/scan_user_body.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/pages/qualifying/qualifying_login_page.dart';
import 'package:frontend/pages/race/race_login_page.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/rest_state.dart';

class DataWedgeState with ChangeNotifier {
  DataWedgeState({required this.gameState, required this.restState});

  final GameState gameState;
  final RestState restState;

  FlutterDataWedge? fdw;
  String? error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> initScanner({bool redirect = false}) async {
    try {
      if (Platform.isAndroid) {
        fdw = FlutterDataWedge();
        await fdw?.initialize();
        await fdw?.createDefaultProfile(profileName: 'f1');
        await fdw?.enableScanner(true);
        await fdw?.activateScanner(true);
        await scanBarcode(redirect: redirect);
      }
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> scanBarcode({bool redirect = false}) async {
    try {
      await fdw?.scannerControl(true);
      listener(redirect: redirect);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  ScanUserBody parseScanResult(ScanResult result) {
    String firstName;
    String surname;
    String country;
    String email;

    final regex = RegExp(r'^(.*?)\^(.*?)\^(.*?)\^(.*?)$');
    final match = regex.firstMatch(result.data);

    if (match != null) {
      firstName = match.group(1) ?? '';
      surname = match.group(2) ?? '';
      country = match.group(3) ?? '';
      email = match.group(4) ?? '';
    } else {
      throw const FormatException('Invalid scan result format');
    }

    return ScanUserBody(firstName, surname, country, email);
  }

  void listener({bool redirect = false}) {
    fdw?.onScanResult.listen((ScanResult result) async {
      if (isLoading) return;
      isLoading = true;
      clear();

      final body = ScanUserBody.fromJsonString(result.data);

      try {
        await restState.postUser(body);
        if (redirect && restState.status == Status.QUALIFYING) {
          router.go(QualifyingLoginPage.name);
        } else if (restState.status == Status.RACE) {
          router.go(RaceLoginPage.name);
          if (gameState.racers.length < 2) {
            unawaited(initScanner());
          }
        }
      } catch (e) {
        unawaited(initScanner());
      }
      isLoading = false;
    });
  }

  void clear() {
    fdw?.scannerControl(false);
    fdw?.enableScanner(false);
    fdw = null;
    error = null;
    isLoading = false;

    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
