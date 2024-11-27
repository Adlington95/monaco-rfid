import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/components/card.dart';
import 'package:frontend/pages/race/race_countdown_page.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class RaceStartPage extends StatelessWidget {
  const RaceStartPage({super.key});
  static const name = '/raceStartPage';

  @override
  Widget build(BuildContext context) {
    final wsState = context.read<WebSocketState>();
    if (!wsState.connected) {
      wsState.connect();
    }

    return Consumer<WebSocketState>(
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (state.raceCarIds.length < 2)
                Column(
                  children: [
                    Text(
                      context.watch<GameState>().racers[state.raceCarIds.isEmpty ? 0 : 1].name,
                      style: const TextStyle(
                        fontSize: 110,
                        fontFamily: 'f1',
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Place your car on the START',
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                TranslucentCard(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => context.go(RaceCountdownPage.name),
                      child: const Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'READY',
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              SvgPicture.asset('assets/car.svg', width: 200, height: 200),
            ].gap(40),
          ),
        );
      },
    );
  }
}
