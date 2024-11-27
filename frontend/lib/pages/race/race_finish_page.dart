import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/components/lap_counter.dart';
import 'package:frontend/components/reset_timer.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class RaceFinishPage extends StatelessWidget {
  const RaceFinishPage({super.key});
  static const String name = '/raceFinishPage';

  @override
  Widget build(BuildContext context) {
    final resetTimerKey = GlobalKey<ResetTimerState>();
    return Stack(
      children: [
        Consumer<WebSocketState>(
          builder: (context, state, _) {
            return Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'WINNER',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 100),
                      ),
                      ConfettiName(name: state.raceWinner!.name, index: state.winningIndex),
                      SvgPicture.asset('assets/car.svg', width: 200, height: 200),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Expanded(child: LapCounter(index: 1)),
                        const Expanded(child: LapCounter(index: 2)),
                      ].gap(40),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ResetTimer(
            key: resetTimerKey,
            onFinish: () => context.go(LeaderBoardsPage.name),
          ),
        ),
      ],
    );
  }
}

class ConfettiName extends StatefulWidget {
  const ConfettiName({
    super.key,
    required this.name,
    required this.index,
  });

  final String name;
  final int index;

  @override
  State<ConfettiName> createState() => _ConfettiNameState();
}

class _ConfettiNameState extends State<ConfettiName> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenter.play();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controllerCenter.state == ConfettiControllerState.playing) {
          _controllerCenter.stop();
        } else {
          _controllerCenter.play();
        }
      },
      child: Stack(
        children: [
          Center(
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              colors: const [Colors.black, Colors.white],
              // canvas: Size.infinite,
              blastDirection: -pi / 2, numberOfParticles: 1000,
            ),
          ),
          Hero(
            tag: 'name-${widget.index}',
            child: Center(
              child: Text(
                widget.name,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 100),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
