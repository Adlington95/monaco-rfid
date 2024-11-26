import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/pages/race_page.dart';
import 'package:go_router/go_router.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class RaceCountdownPage extends StatefulWidget {
  const RaceCountdownPage({super.key});
  static const String name = '/raceCountdownPage';

  @override
  State<RaceCountdownPage> createState() => _RaceCountdownPageState();
}

class _RaceCountdownPageState extends State<RaceCountdownPage> {
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

      setState(() => lightState[i] = true);
    }
    final delay2 = random.nextInt(1500) + 1000;
    await Future<void>.delayed(Duration(milliseconds: delay2));
    setState(() {
      lightState.fillRange(0, lightState.length, false);
    });
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
