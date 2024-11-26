import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/components/card.dart';
import 'package:frontend/components/dashboard.dart';

import 'package:frontend/components/formatted_duration.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';

class LiveTiming extends StatelessWidget {
  const LiveTiming({
    super.key,
    this.index,
  });

  final int? index;

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FittedBox(
                child: Text(
                  context.read<GameState>().loggedInUser?.name ?? 'Player ${index == null ? '1' : index.toString()}',
                  style: const TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
              TranslucentCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SvgPicture.asset('lib/assets/monaco.svg', height: 180),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'LAP ${index != null ? state.getCurrentLapFromIndex(index!) : state.currentLap}/${state.totalLaps}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 48,
                                color: Colors.white,
                              ),
                            ),
                            Column(
                              children: [
                                const Text(
                                  'FASTEST LAP',
                                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                                FormattedDuration(
                                  Duration(
                                    milliseconds:
                                        index != null ? state.getFastestLapFromIndex(index!) : state.fastestLap,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Dashboard(),
            ],
          ),
        );
      },
    );
  }
}
