import 'package:flutter/material.dart';
import 'package:frontend/components/card.dart';
import 'package:frontend/components/lap_row_item.dart';
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
                                ? state.restState.gameState.settings.raceLaps
                                : state.restState.gameState.settings.qualifyingLaps,
                            (lap) => LapRowItem(lap: lap + 1, index: index),
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
