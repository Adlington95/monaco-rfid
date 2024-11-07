import 'package:flutter/material.dart';
import 'package:flutterfrontend/components/leaderboard.dart';
import 'package:flutterfrontend/pages/scan_id.dart';
import 'package:flutterfrontend/state/dw_state.dart';
import 'package:flutterfrontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/driver_standing_item.dart';

class LeaderBoardsPage extends StatefulWidget {
  static const String name = '/leaderboards';

  const LeaderBoardsPage({super.key});

  @override
  State<LeaderBoardsPage> createState() => _LeaderBoardsPageState();
}

class _LeaderBoardsPageState extends State<LeaderBoardsPage> {
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataWedgeState>(context, listen: false).clear();
      Provider.of<WebSocketState>(context, listen: false).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(fontFamily: 'Titillium'),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: GestureDetector(
          onTap: () => context.go(ScanIdPage.name),
          child: Row(
            children: [
              Expanded(
                child: Leaderboard(driverStandings: driverStandings),
              ),
              // const SizedBox(width: 40),
              // Expanded(
              //   child: Leaderboard(constructorStandings: constructorStandings),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
