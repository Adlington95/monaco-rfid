import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/components/card.dart';
import 'package:frontend/components/dashboard.dart';

import 'package:frontend/components/formatted_duration.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class LiveTiming extends StatelessWidget {
  const LiveTiming({super.key, this.index});

  final int? index;

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, _) {
        final String userName;

        if (state.restState.gameState.loggedInUser != null) {
          userName = state.restState.gameState.loggedInUser!.name;
        } else if (state.restState.gameState.racers.isNotEmpty &&
            index != null &&
            index! - 1 < state.restState.gameState.racers.length) {
          userName = state.restState.gameState.racers[index! - 1].name;
        } else {
          userName = 'Player ${index == null ? '1' : index.toString()}';
        }

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FittedBox(
                child: Hero(
                  tag: 'name-$index',
                  child: Text(
                    userName.trim(),
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              TranslucentCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/monaco.svg', height: state.restState.gameState.isEmulator ? 160 : 180),
                      if (state.restState.gameState.isEmulator)
                        ZetaButton(
                          label: 'Fake lap',
                          onPressed: () {
                            if (index != null) state.fakeLapTime(index!);
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'LAP ${(index != null ? state.getCurrentLapFromIndex(index!) : state.currentLap).clamp(1, state.maxLaps)}/${state.totalLaps}',
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
                                        index != null ? state.getFastestLapFromIndex(index!) : state.fastestLap ?? 0,
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
              Dashboard(index: index),
            ],
          ),
        );
      },
    );
  }
}
