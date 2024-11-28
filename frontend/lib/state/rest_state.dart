// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/driver_standing_item.dart';
import 'package:frontend/models/scan_user_body.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/qualifying/qualifying_login_page.dart';
import 'package:frontend/pages/race/race_start_page.dart';
import 'package:frontend/state/game_state.dart';
import 'package:http/http.dart' as http;

class RestState with ChangeNotifier {
  RestState({required this.gameState}) {
    initState();
  }

  final GameState gameState;
  List<DriverStandingItem>? driverStandings;

  Status _status = Status.UNKNOWN;
  Status get status => _status;
  set status(Status value) {
    _status = value;
    notifyListeners();
  }

  void initState() {
    getStatus(retry: true);
  }

  Future<void> postLap(int fastestLap, int overallTime, String carId) async {
    await http.post(
      Uri.parse('${gameState.restUrl}/lap'),
      body: jsonEncode({
        'lap_time': fastestLap,
        'overall_time': overallTime,
        'attempts': gameState.loggedInUser?.previousAttempts,
        'car_id': carId,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> fetchDriverStandings() async {
    try {
      final response = await http.get(Uri.parse('${gameState.restUrl}/getLeaderboard'));
      final newStandings = <DriverStandingItem>[];
      if (response.statusCode == 200) {
        var foundNewRecord = false;
        (jsonDecode(response.body) as List<dynamic>).forEachIndexed((index, standing) {
          var newItem = DriverStandingItem.fromJson(standing as Map<String, dynamic>);
          if (driverStandings != null && driverStandings!.isNotEmpty) {
            if (!foundNewRecord) {
              if (newItem.id != driverStandings?[index].id) {
                foundNewRecord = true;
                newItem = newItem.copyWith(change: PlaceChange.up, newRecord: true);
              }
            } else {
              newItem = newItem.copyWith(change: PlaceChange.down);
            }
          }
          newStandings.add(newItem);
        });
        driverStandings = [...newStandings];
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    notifyListeners();
  }

  Future<Status> getStatus({bool retry = false}) async {
    try {
      debugPrint('Getting status:  ${gameState.restUrl}');
      final response = await http.get(Uri.parse('${gameState.restUrl}/status')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        unawaited(fetchDriverStandings());

        status = Status.values[((await json.decode(response.body))['status'] as int) - 1];
      }
    } catch (e) {
      debugPrint(e.toString());
      status = Status.UNKNOWN;
    }
    if (retry && status == Status.UNKNOWN) {
      await Future<void>.delayed(const Duration(seconds: 2));
      unawaited(getStatus(retry: true));
    }
    debugPrint('Status: $status');
    return status;
  }

  Future<void> resetStatus({Status status = Status.READY}) async {
    debugPrint('Resetting status');
    try {
      final response = await http.post(
        Uri.parse('${gameState.restUrl}/status'),
        body: jsonEncode({'status': status.index + 1}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        this.status = status;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> postUser(ScanUserBody body) async {
    try {
      final res = await http.post(
        Uri.parse('${gameState.restUrl}/scanUser'),
        body: jsonEncode({'id': body.id, 'name': body.name}),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        if (res.body.isEmpty) {
          final newUser = User(
            name: body.name,
            previousAttempts: 0,
            employeeId: body.id,
          );
          if (status == Status.RACE) {
            gameState.addRacer(newUser);
            notifyListeners();
            if (gameState.racers.length == 2) {
              unawaited(
                Future<void>.delayed(const Duration(milliseconds: 1500)).then((value) {
                  router.pushReplacement(RaceStartPage.name);
                }),
              );
            }
          } else {
            gameState.loggedInUser = newUser;
          }
          return;
        }
        final userObj = jsonDecode(res.body) as Map<String, dynamic>;
        final user = User.fromJson(userObj);
        if (status == Status.RACE) {
          gameState.addRacer(user);
          if (gameState.racers.length == 2) {
            unawaited(
              Future<void>.delayed(const Duration(milliseconds: 1500)).then((value) {
                router.pushReplacement(RaceStartPage.name);
              }),
            );
          }
        } else {
          gameState.loggedInUser = user;
        }

        if (MyApp.navigatorKey.currentContext != null &&
            ModalRoute.of(MyApp.navigatorKey.currentContext!)?.settings.name != ScanIdPage.name &&
            status != Status.RACE) {
          router.go(ScanIdPage.name);
        }
      } else if (res.statusCode == 400 && res.body.contains('User already scanned')) {
        unawaited(
          Fluttertoast.showToast(
            msg: 'User already scanned',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 32,
          ),
        );
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
      rethrow;
    }
  }

  Future<void> startRace() async {
    final res = await http.post(
      Uri.parse('${gameState.restUrl}/startRace'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      return;
    } else {
      debugPrint(res.body);
      unawaited(Fluttertoast.showToast(msg: 'Unable to start race. Please try again', toastLength: Toast.LENGTH_SHORT));
      throw Exception('Failed to start race');
    }
  }

  Future<void> resetRFID() async {
    await http.post(
      Uri.parse('${gameState.restUrl}/resetRFID'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> reset() async {
    await http.post(
      Uri.parse('${gameState.restUrl}/reset'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> removeUser(String id) async {
    await http.post(
      Uri.parse('${gameState.restUrl}/removeEntry'),
      body: jsonEncode({'id': id}),
      headers: {'Content-Type': 'application/json'},
    );
    await fetchDriverStandings();
  }

  Future<void> raceReady() async => http.get(Uri.parse('${gameState.restUrl}/raceReady'));

  void clear() {
    resetStatus();

    notifyListeners();
  }
}
