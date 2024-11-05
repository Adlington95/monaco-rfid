import 'package:flutter/material.dart';
import 'package:flutterfrontend/components/card.dart';
import 'package:flutterfrontend/components/leaderboard_entry.dart';
import 'package:flutterfrontend/models/constructor_standing_item.dart';
import 'package:flutterfrontend/models/driver_standing_item.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({
    super.key,
    this.driverStandings,
    this.constructorStandings,
  });

  final List<DriverStandingItem>? driverStandings;
  final List<ConstructorStandingItem>? constructorStandings;

  @override
  Widget build(BuildContext context) {
    return TranslucentCard(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Stack(
          children: [
            Text(
              driverStandings != null
                  ? 'Driver Standings'
                  : constructorStandings != null
                      ? 'Constructor Standings'
                      : '',
              style: const TextStyle(fontSize: 40),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 20),
                child: LeaderboardEntry(
                  isDriverHeader: driverStandings != null,
                )),
          ],
        ),
        if ((driverStandings ?? constructorStandings) != null)
          Column(
            children: (driverStandings ?? constructorStandings ?? [])
                .map(
                  (element) => LeaderboardEntry(
                    driver: element.runtimeType == DriverStandingItem ? element as DriverStandingItem : null,
                    constructor:
                        element.runtimeType == ConstructorStandingItem ? element as ConstructorStandingItem : null,
                    index: (driverStandings ?? constructorStandings ?? []).indexOf(element) + 1,
                  ),
                )
                .toList(),
          )
      ]),
    ));
  }
}
