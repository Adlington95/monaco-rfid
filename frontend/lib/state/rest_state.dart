import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutterfrontend/constants.dart';
import 'package:flutterfrontend/models/driver_standing_item.dart';
import 'package:http/http.dart' as http;

class RestState with ChangeNotifier {
  final List<DriverStandingItem> driverStandings = [];

  Future<void> postFastestLap(double fastestLap) async {
    await http.post(
      Uri.parse('$restUrl/lap'),
      body: jsonEncode({'lap': fastestLap}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> fetchDriverStandings() async {
    // final response = await http.get(Uri.parse('$restUrl/getLeaderboard'));
    // final newStandings = <DriverStandingItem>[];
    // if (response.statusCode == 200) {
    //   var foundNewRecord = false;
    //   (jsonDecode(response.body) as List<dynamic>).forEachIndexed((index, standing) {
    //     var newItem = DriverStandingItem.fromJson(standing as Map<String, dynamic>);
    //     if (driverStandings.isNotEmpty) {
    //       if (!foundNewRecord) {
    //         if (newItem.id != driverStandings[index].id) {
    //           foundNewRecord = true;
    //           newItem = newItem.copyWith(change: PlaceChange.up, newRecord: true);
    //         }
    //       } else {
    //         newItem = newItem.copyWith(change: PlaceChange.down);
    //       }
    //     }
    //     newStandings.add(newItem);
    //   });
    //   driverStandings
    //     ..clear()
    //     ..addAll(newStandings);
    // }
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final random = Random();
    final newStandings = List.generate(80, (index) {
      return DriverStandingItem(
        'Driver $index',
        index.toString(),
        random.nextInt(50),
        (100000 + (100000 * (0.1 + 0.9 * (random.nextInt(10000000)) / 1000))).toInt(),
      );
    });

    driverStandings
      ..clear()
      ..addAll(newStandings);

    notifyListeners();
  }

  void clear() {
    driverStandings.clear();
    notifyListeners();
  }
}
