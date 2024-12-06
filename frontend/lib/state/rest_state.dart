// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/main.dart';
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
  static const fakeCarId1 = '1234567890';
  static const fakeCarId2 = '0987654321';

  bool _rfidResetting = false;

  bool get rfidResetting => _rfidResetting;

  set rfidResetting(bool value) {
    _rfidResetting = value;
    notifyListeners();
  }

  final GameState gameState;
  List<User>? lapLeaderboard;
  List<User>? overallLeaderboard;

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
      Uri.parse('${gameState.settings.restUrl}/lap'),
      body: jsonEncode({
        'lap_time': fastestLap,
        'overall_time': overallTime,
        'attempts': (gameState.loggedInUser?.previousAttempts ?? 0) + 1,
        'car_id': carId,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> fetchDriverStandings() async {
    final futures = [
      getLapLeaderboard,
      getOverallLeaderboard,
    ];

    try {
      await Future.wait(futures.map((e) => e()));
    } catch (e) {
      debugPrint(e.toString());
    }

    notifyListeners();
  }

  Future<List<User>> getLapLeaderboard() {
    return http.get(Uri.parse('${gameState.settings.restUrl}/getLeaderboard')).then((response) {
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        final users = list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
        lapLeaderboard = users;
        return users;
      } else {
        throw Exception('Failed to get lap leaderboard');
      }
    });
  }

  Future<List<User>> getOverallLeaderboard() {
    return http.get(Uri.parse('${gameState.settings.restUrl}/getOverallLeaderboard')).then((response) {
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        var users = list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
        final newIndex = users.indexWhere((element) => element.employeeId == gameState.loggedInUser?.employeeId);

        if (gameState.loggedInUser != null &&
            overallLeaderboard != null &&
            overallLeaderboard!.any((element) => element.employeeId == gameState.loggedInUser!.employeeId)) {
          final formerIndex =
              overallLeaderboard!.indexWhere((element) => element.employeeId == gameState.loggedInUser!.employeeId);

          if (newIndex != formerIndex) {
            users = users.mapIndexed((index, e) {
              if (newIndex < formerIndex) {
                // User moved up
                if (index == newIndex) {
                  return e.copyWith(change: PlaceChange.up);
                } else if (index > newIndex && index <= formerIndex) {
                  return e.copyWith(change: PlaceChange.down);
                } else {
                  return e;
                }
              } else {
                // User moved down
                if (index == newIndex) {
                  return e.copyWith(change: PlaceChange.down);
                } else if (index < newIndex && index >= formerIndex) {
                  return e.copyWith(change: PlaceChange.up);
                } else {
                  return e;
                }
              }
            }).toList();
          }
        } else if (gameState.loggedInUser != null && overallLeaderboard != null) {
          users = users.mapIndexed((index, e) {
            if (index == newIndex) {
              return e.copyWith(change: PlaceChange.up);
            } else if (index > newIndex) {
              return e.copyWith(change: PlaceChange.down);
            } else {
              return e;
            }
          }).toList();
        }
        overallLeaderboard = users;
        return users;
      } else {
        throw Exception('Failed to get overall leaderboard');
      }
    });
  }

  Future<Status> getStatus({bool retry = false}) async {
    try {
      debugPrint('Getting status:  ${gameState.settings.restUrl}');
      final response =
          await http.get(Uri.parse('${gameState.settings.restUrl}/status')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        unawaited(fetchDriverStandings());

        status = Status.values[((await json.decode(response.body))['status'] as int)];
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

  Future<void> resetStatus({Status status = Status.QUALIFYING}) async {
    debugPrint('Resetting status');
    try {
      final response = await http.post(
        Uri.parse('${gameState.settings.restUrl}/status'),
        body: jsonEncode({'status': status.index}),
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
        Uri.parse('${gameState.settings.restUrl}/scanUser'),
        body: jsonEncode(body.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        if (res.body.isEmpty) {
          final newUser = User(
            name: '${body.firstName} ${body.surname}',
            previousAttempts: 0,
            employeeId: body.email,
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
            ModalRoute.of(MyApp.navigatorKey.currentContext!)?.settings.name != QualifyingLoginPage.name &&
            status != Status.RACE) {
          router.go(QualifyingLoginPage.name);
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
      Uri.parse('${gameState.settings.restUrl}/startRace'),
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
    rfidResetting = true;
    try {
      final res = await http.post(
        Uri.parse('${gameState.settings.restUrl}/resetRFID'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode != 200) {
        debugPrint(res.body);
        unawaited(
          Fluttertoast.showToast(msg: 'Unable to reset RFID. Please try again', toastLength: Toast.LENGTH_SHORT),
        );
        throw Exception('Failed to reset RFID');
      } else {
        unawaited(
          Fluttertoast.showToast(msg: 'RFID Reset', toastLength: Toast.LENGTH_SHORT),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      rfidResetting = false;
    }
  }

  Future<void> reset() async {
    await http.post(
      Uri.parse('${gameState.settings.restUrl}/reset'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> removeUser(String id) async {
    await http.post(
      Uri.parse('${gameState.settings.restUrl}/removeEntry'),
      body: jsonEncode({'id': id}),
      headers: {'Content-Type': 'application/json'},
    );
    await fetchDriverStandings();
  }

  Future<void> raceReady() async => http.get(Uri.parse('${gameState.settings.restUrl}/raceReady'));

  void fakeRFID(String fakeCarId, [DateTime? time]) {
    final timeString = ((time ?? DateTime.now()).toIso8601String().split('.')..removeLast()).join('.');

    http.post(
      Uri.parse('${gameState.settings.restUrl}/rfid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode([
        {
          'timestamp': timeString,
          'data': {
            'idHex': fakeCarId,
          },
        }
      ]),
    );
  }

  void clear() {
    resetStatus();

    notifyListeners();
  }
}
