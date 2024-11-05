import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutterfrontend/components/id_card.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class ScanIdPage extends StatefulWidget {
  const ScanIdPage({super.key});

  @override
  State<ScanIdPage> createState() => _ScanIdPageState();
}

class _ScanIdPageState extends State<ScanIdPage> {
  late FlutterDataWedge fdw;
  Future<void>? initScannerResult;

  @override
  void initState() {
    super.initState();
    initScannerResult = initScanner();
  }

  void listener() {
    fdw.onScanResult.listen((ScanResult result) async {
      try {
        final obj = jsonDecode(result.data);
        final res = await http.post(Uri.parse('localhost:3000/userscan'), body: obj);
        if (res.statusCode == 200) {
          final userObj = jsonDecode(res.body);
          userObj['id'] = userObj['id'].toString();

          final user = User(userObj['name'], userObj['id'], userObj['attempts'], userObj['company']);
          if (context.mounted && mounted) context.go('/welcome', extra: user);
        } else {
          throw Exception('Failed to scan user');
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  Future<void> initScanner() async {
    if (Platform.isAndroid) {
      fdw = FlutterDataWedge();
      await fdw.initialize();
      await fdw.createDefaultProfile(profileName: 'f1');
      fdw.enableScanner(true);
      fdw.activateScanner(true);
      scanBarcode(init: true);
    }
  }

  Future<void> scanBarcode({bool init = false}) async {
    try {
      fdw.scannerControl(true);
      listener();
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!init && kDebugMode) {
      context.go('/welcome', extra: User('Marc Adlington Marc Adlington Marc ', '747474929', 1000, 'Aston Martin'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initScannerResult,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return IdCard(title: 'Scan your ID card', onTap: scanBarcode);
        }
      },
    );
  }
}
