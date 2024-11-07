import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutterfrontend/components/id_card.dart';
import 'package:flutterfrontend/constants.dart';
import 'package:flutterfrontend/main.dart';
import 'package:flutterfrontend/models/scan_user_body.dart';
import 'package:flutterfrontend/pages/car_start.dart';
import 'package:http/http.dart' as http;

class DataWedgeState with ChangeNotifier {
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

  Future<void> changePage() async {
    if (loggedInUser != null) {
      await Future.delayed(const Duration(seconds: 5));
      if (loggedInUser != null) router.go(CarStartPage.name, extra: loggedInUser);
    }
  }

  Future<void> initScanner() async {
    try {
      if (Platform.isAndroid) {
        fdw = FlutterDataWedge();
        await fdw?.initialize();
        await fdw?.createDefaultProfile(profileName: 'f1');
        fdw?.enableScanner(true);
        fdw?.activateScanner(true);
        scanBarcode(init: true);
      }
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> scanBarcode({bool init = false}) async {
    try {
      fdw?.scannerControl(true);
      listener();
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!init && kDebugMode) {
      loggedInUser = User('Marc Adlington', '747474929', 1000, 'Aston Martin');
      notifyListeners();
    }
  }

  void listener() {
    fdw?.onScanResult.listen((ScanResult result) async {
      try {
        final obj = jsonDecode(result.data);

        final ScanUserBody body = ScanUserBody.fromJson(obj);
        final res = await http.post(Uri.parse('$restUrl/scanUser'), body: body.toJson());

        if (res.statusCode == 200) {
          final userObj = jsonDecode(res.body);
          userObj['id'] = userObj['id'].toString();
          final user = User(userObj['name'], userObj['id'], userObj['attempts'], userObj['company']);
          loggedInUser = user;
        } else {
          throw Exception('Failed to scan user');
        }
      } catch (e) {
        debugPrint(e.toString());
      }
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
