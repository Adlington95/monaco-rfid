import 'package:flutter/material.dart';
import 'package:flutterfrontend/components/leaderboard.dart';
import 'package:flutterfrontend/pages/scan_id.dart';
import 'package:flutterfrontend/state/dw_state.dart';
import 'package:flutterfrontend/state/rest_state.dart';
import 'package:flutterfrontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LeaderBoardsPage extends StatefulWidget {
  const LeaderBoardsPage({super.key});
  static const String name = '/leaderboards';

  @override
  State<LeaderBoardsPage> createState() => _LeaderBoardsPageState();
}

class _LeaderBoardsPageState extends State<LeaderBoardsPage> {
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
    return FutureBuilder(
      future: Provider.of<RestState>(context, listen: false).fetchDriverStandings(),
      builder: (context, future) {
        if (future.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (future.hasError) {
          return const Center(child: Text('Error fetching driver standings'));
        }

        return Padding(
          padding: const EdgeInsets.only(top: 140, left: 140, right: 140),
          child: GestureDetector(
            onTap: () => context.go(ScanIdPage.name),
            child: const Leaderboard(),
          ),
        );
      },
    );
  }
}
