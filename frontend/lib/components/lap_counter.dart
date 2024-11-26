import 'package:flutter/material.dart';
import 'package:frontend/components/card.dart';
import 'package:frontend/components/formatted_duration.dart';
import 'package:frontend/components/leaderboard_row.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class LapCounter extends StatelessWidget {
  const LapCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'lap-counter',
      child: TranslucentCard(
        child: Padding(
          padding: const EdgeInsets.all(24).copyWith(right: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('LAP TIMES', style: TextStyle(fontSize: 40, color: Colors.white)),
              Center(
                child: Column(
                  children:
                      List.generate(context.read<GameState>().qualifyingLaps, (index) => RowItem(index: index + 1))
                          .gap(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RowItem extends StatelessWidget {
  const RowItem({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, child) {
        final time = state.lapTime(index);

        return LeaderboardRow(
          index: index,
          isPurple: double.tryParse(time) != null && double.parse(time).toInt() == state.fastestLap,
          child: double.tryParse(time) != null
              ? FormattedDuration(
                  Duration(milliseconds: double.parse(time).toInt()),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300, fontFamily: 'Titillium'),
                )
              : const Nothing(),
        );
      },
    );
  }
}
