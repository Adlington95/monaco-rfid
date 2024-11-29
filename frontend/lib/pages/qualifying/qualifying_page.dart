import 'package:flutter/material.dart';
import 'package:frontend/components/lap_counter.dart';
import 'package:frontend/components/live_timing.dart';

class QualifyingPage extends StatelessWidget {
  const QualifyingPage({super.key});
  static const name = '/qualifying';

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 6, child: LapCounter()),
        Expanded(flex: 7, child: LiveTiming()),
      ],
    );
  }
}
