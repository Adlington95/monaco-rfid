import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/pages/race/race_page.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class RaceCountdownPage extends StatefulWidget {
  const RaceCountdownPage({super.key});
  static const String name = '/raceCountdownPage';

  @override
  State<RaceCountdownPage> createState() => _RaceCountdownPageState();
}

class _RaceCountdownPageState extends State<RaceCountdownPage> {
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lights();
    });
  }

  Future<void> lights() async {
    final random = Random();
    final delay1 = random.nextInt(1500) + 1000;
    await Future<void>.delayed(Duration(milliseconds: delay1));
    for (var i = 0; i < lightState.length; i++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      unawaited(player.play(AssetSource('light_out.mp3')));
      setState(() => lightState[i] = true);
    }
    final delay2 = random.nextInt(1500) + 1000;
    await Future<void>.delayed(Duration(milliseconds: delay2));
    setState(() {
      lightState.fillRange(0, lightState.length, false);
    });
    if (mounted) await context.read<RestState>().startRace();
    await Future<void>.delayed(const Duration(seconds: 3));
    if (mounted) context.go(RacePage.name);
  }

  final lightState = List.filled(5, false);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const GameTitle(isExpanded: false),
        IntrinsicWidth(child: Row(children: lightState.map((e) => Light(on: e)).gap(40))),
        const SizedBox(height: 100),
        const SizedBox(
          width: 400,
          child: Hero(
            tag: 'raceInstructions',
            child: FittedBox(
              child: Text(
                "Don't go until all the lights are out",
                style: TextStyle(
                  fontSize: 80,
                  fontFamily: 'f1',
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
        ),
      ].gap(100),
    );
  }
}

class Light extends StatelessWidget {
  const Light({super.key, required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? Colors.red : Colors.grey[900],
      ),
    );
  }
}
