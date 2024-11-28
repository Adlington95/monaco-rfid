import 'package:flutter/material.dart';
import 'package:frontend/components/card.dart';
import 'package:frontend/components/formatted_duration.dart';
import 'package:frontend/components/leaderboard_row.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class LapCounter extends StatelessWidget {
  const LapCounter({super.key, this.index});
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, _) {
        return Hero(
          tag: 'lap-counter-$index',
          child: TranslucentCard(
            child: Padding(
              padding: const EdgeInsets.all(24).copyWith(right: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    index != null ? state.restState.gameState.racers[index! - 1].name : 'LAP TIMES',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: List.generate(
                            index != null
                                ? state.restState.gameState.raceLaps
                                : state.restState.gameState.qualifyingLaps,
                            (lap) => RowItem(lap: lap + 1, index: index),
                          ).gap(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RowItem extends StatelessWidget {
  const RowItem({super.key, required this.lap, this.index});

  final int lap;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, child) {
        final time = index != null ? state.raceLapTime(lap, index!) : state.qualifyingLapTime(lap);
        final isPurple = index != null
            ? time == state.fastestRaceLap.toStringAsFixed(3)
            : double.tryParse(time) != null &&
                double.parse(time).toInt() == state.fastestLap &&
                (state.restState.gameState.loggedInUser == null ||
                    (state.restState.gameState.loggedInUser != null &&
                        state.restState.gameState.loggedInUser!.previousFastestLap != null &&
                        state.restState.gameState.loggedInUser!.previousFastestLap! > state.fastestLap));

        final isGreen =
            index == null && double.tryParse(time) != null && double.parse(time).toInt() == state.fastestLap;

        final isRed = index != null && state.invalidatedLap(lap, index!); // TODO: get this from the server

        return LeaderboardRow(
          index: lap,
          isPurple: isPurple,
          isRed: isRed,
          isGreen: isGreen,
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
