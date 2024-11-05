import 'package:flutter/material.dart';
import 'package:flutterfrontend/components/leaderboard.dart';
import 'package:flutterfrontend/models/constructor_standing_item.dart';
import 'package:go_router/go_router.dart';

import '../models/driver_standing_item.dart';

class LeaderBoardsPage extends StatelessWidget {
  final List<DriverStandingItem> driverStandings = [
    const DriverStandingItem('Driver 1', 3, 'LEADER', PlaceChange.none, false),
    const DriverStandingItem('Driver 2', 4, '+0.5535s', PlaceChange.none, false),
    const DriverStandingItem('Driver 3', 5, '+0.7625s', PlaceChange.none, false),
    const DriverStandingItem('Driver 4', 6, '+1.2343s', PlaceChange.none, false),
    const DriverStandingItem('Driver 5', 7, '+1.5333s', PlaceChange.none, false),
    const DriverStandingItem('Driver 6', 8, '+1.7999s', PlaceChange.none, false),
    const DriverStandingItem('Driver 7', 9, '+2.2896s', PlaceChange.up, true),
    const DriverStandingItem('Driver 8', 10, '+2.5789s', PlaceChange.down, false),
  ];

  final List<ConstructorStandingItem> constructorStandings = [
    ConstructorStandingItem('Mclaren', PlaceChange.none, false, color: Colors.orange),
    ConstructorStandingItem('Ferrari', PlaceChange.none, false, color: Colors.red),
    ConstructorStandingItem('Red Bull', PlaceChange.none, false, color: Colors.deepPurple),
    ConstructorStandingItem('Mercedes', PlaceChange.none, false, color: Colors.blue),
    ConstructorStandingItem('Aston Martin', PlaceChange.none, false, color: Colors.teal),
    ConstructorStandingItem('Alpine', PlaceChange.none, false, color: Colors.blueAccent.shade700),
    ConstructorStandingItem('Williams', PlaceChange.up, true, color: Colors.blue),
    ConstructorStandingItem('Haaaas', PlaceChange.down, false, color: Colors.redAccent.shade700),
  ];

  LeaderBoardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(fontFamily: 'Titillium'),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: GestureDetector(
          onTap: () => context.go('/scan-id'),
          child: Row(
            children: [
              Expanded(
                child: Leaderboard(driverStandings: driverStandings),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Leaderboard(constructorStandings: constructorStandings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
