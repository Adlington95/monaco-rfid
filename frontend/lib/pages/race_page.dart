import 'package:flutter/material.dart';
import 'package:frontend/components/live_timing.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:provider/provider.dart';

class RacePage extends StatelessWidget {
  const RacePage({super.key});
  static const String name = '/racePage';

  @override
  Widget build(BuildContext context) {
    if (context.read<RestState>().status != Status.RACE) {
      context.read<RestState>().resetStatus(status: Status.RACE);
    }
    return const Row(
      children: [
        Expanded(child: LiveTiming(index: 1)),
        Expanded(child: LiveTiming(index: 2)),
      ],
    );
  }
}
