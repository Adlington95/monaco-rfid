import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/components/leaderboard.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/pages/qualifying/qualifying_login_page.dart';
import 'package:frontend/pages/race/race_login_page.dart';
import 'package:frontend/pages/settings_page.dart';
import 'package:frontend/state/dw_state.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

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
      Provider.of<RestState>(context, listen: false).clear();
      Provider.of<WebSocketState>(context, listen: false).clear();
      Provider.of<GameState>(context, listen: false).clear();

      context.read<DataWedgeState>().initScanner(redirect: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 10,
          right: 10,
          child: GestureDetector(
            onLongPress: () {
              Provider.of<DataWedgeState>(context, listen: false).clear();
              context.push(SettingsPage.name);
            },
            child: Icon(
              ZetaIcons.settings,
              color: Zeta.of(context).colors.textInverse.withOpacity(0.2),
              size: 60,
            ),
          ),
        ),
        GestureDetector(
          onTap: () =>
              context.push(context.read<RestState>().status == Status.RACE ? RaceLoginPage.name : ScanIdPage.name),
          child: PopScope(
            canPop: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 80, right: 80, bottom: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(child: GameTitle()),
                      Row(
                        children: [
                          const Text('Qualifying'),
                          ZetaSwitch(
                            value: context.watch<RestState>().status == Status.RACE,
                            onChanged: (x) {
                              if (x != null) {
                                context.read<RestState>().resetStatus(status: x ? Status.RACE : Status.QUALIFYING);
                                context.read<DataWedgeState>().initScanner(
                                      redirect: true,
                                    );
                              }
                            },
                          ),
                          const Text('Race'),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Box(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: context.watch<RestState>().overallLeaderboard == null
                                ? const Center(child: CircularProgressIndicator())
                                : const Leaderboard(),
                          ),
                          Expanded(
                            flex: 3,
                            child: context.watch<RestState>().lapLeaderboard == null
                                ? const Center(child: CircularProgressIndicator())
                                : const Leaderboard(lapType: LapType.lap),
                          ),
                        ].gap(40),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.grey,
                    period: const Duration(milliseconds: 2500),
                    child: Text(
                      'To start a new game, scan your ${context.watch<GameState>().scannedThingName} below or tap the screen',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ).paddingTop(40),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Box extends StatelessWidget {
  const Box({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.93, -0.36),
          end: const Alignment(-0.93, 0.36),
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.1),
          ],
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 120,
            offset: Offset(0, 61.34),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GameTitle extends StatelessWidget {
  const GameTitle({super.key, this.isExpanded = true});
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final container = Hero(
      tag: 'game-title',
      child: Container(
        margin: const EdgeInsets.only(bottom: 6, left: 4),
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 8,
              strokeAlign: BorderSide.strokeAlignCenter,
              color: Colors.white,
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(34), topRight: Radius.circular(34)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/zebra-word.svg', height: 60),
              Text(
                Provider.of<GameState>(context).eventName,
                style: const TextStyle(
                  fontSize: 42,
                  color: Colors.white,
                  fontFamily: 'F1',
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return isExpanded
        ? Row(
            children: [
              Expanded(
                flex: 2,
                child: container,
              ),
              const Expanded(child: Nothing()),
            ],
          )
        : container;
  }
}
