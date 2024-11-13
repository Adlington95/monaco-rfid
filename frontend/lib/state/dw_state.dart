import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/components/id_card.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/scan_user_body.dart';
import 'package:frontend/pages/car_start.dart';
import 'package:frontend/state/game_state.dart';
import 'package:http/http.dart' as http;

class DataWedgeState with ChangeNotifier {
  DataWedgeState({required this.gameState});

  final GameState gameState;

  FlutterDataWedge? fdw;
  String? error;

  User? _loggedInUser;
  User? get loggedInUser => _loggedInUser;
  set loggedInUser(User? value) {
    _loggedInUser = value;
    if (value != null) {
      notifyListeners();
      changePage();
    }
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> changePage() async {
    if (loggedInUser != null) {
      await Future<void>.delayed(const Duration(seconds: 5));
      if (loggedInUser != null) await router.pushReplacement(CarStartPage.name, extra: loggedInUser);
    }
  }

  Future<void> initScanner() async {
    try {
      if (Platform.isAndroid) {
        fdw = FlutterDataWedge();
        await fdw?.initialize();
        await fdw?.createDefaultProfile(profileName: 'f1');
        await fdw?.enableScanner(true);
        await fdw?.activateScanner(true);
        await scanBarcode(init: true);
      }
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> scanBarcode({bool init = false}) async {
    try {
      await fdw?.scannerControl(true);
      listener();
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!init && debugMode) {
      loggedInUser = User('Marc Adlington', 1000, '747474929');
      notifyListeners();
    }
  }

  void listener() {
    fdw?.onScanResult.listen((ScanResult result) async {
      isLoading = true;
      clear();
      try {
        ScanUserBody body;

        try {
          final obj = jsonDecode(result.data);
          body = ScanUserBody.fromJson(obj as Map<String, dynamic>);
        } catch (e) {
          body = ScanUserBody(result.data, result.data);
        }
        final res = await http.post(
          Uri.parse('${gameState.restUrl}/scanUser'),
          body: jsonEncode({'id': body.id, 'name': body.name}),
          headers: {'Content-Type': 'application/json'},
        );

        if (res.statusCode == 200) {
          if (res.body == '[]') {
            loggedInUser = User(body.name, 0, body.id);
            return;
          }
          final userObj = jsonDecode(res.body) as Map<String, dynamic>;
          userObj['id'] = userObj['id'].toString();
          final user = User(
            userObj['name'] as String,
            userObj['attempts'] as int,
            userObj['id'] as String,
            // userObj['company'] as String,
          );
          loggedInUser = user;
        } else {
          throw Exception('Failed to scan user');
        }
      } catch (e) {
        unawaited(
          Fluttertoast.showToast(
            msg: 'Unable to connect to server',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 32,
          ),
        );
        debugPrint(e.toString());
        unawaited(initScanner());
      }
      isLoading = false;
    });
  }

  void clear() {
    fdw?.scannerControl(false);
    fdw?.enableScanner(false);
    loggedInUser = null;
    fdw = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
