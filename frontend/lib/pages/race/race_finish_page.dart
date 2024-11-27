import 'package:flutter/material.dart';
import 'package:frontend/components/lap_counter.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class RaceFinishPage extends StatelessWidget {
  const RaceFinishPage({super.key});
  static const String name = '/raceFinishPage';

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, _) {
        return Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'WINNER',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 100),
                  ),
                  Hero(
                    tag: 'name-${state.winningIndex}',
                    child: Text(
                      state.raceWinner!.name,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 100),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Expanded(child: LapCounter(index: 1)),
                  const Expanded(child: LapCounter(index: 2)),
                ].gap(40),
              ),
            ),
          ],
        );
      },
    );
  }
}
