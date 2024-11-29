import 'package:flutter/material.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';

class PracticeCountdownPage extends StatelessWidget {
  const PracticeCountdownPage({super.key});
  static const name = '/practice-countdown';

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, child) => GestureDetector(
        onTap: Provider.of<GameState>(context).isEmulator ? () => state.fakeLapTime() : null,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(60),
            child: Text(
              '${state.practiceLapsRemainingString} PRACTICE LAP${state.practiceLapsRemainingString == '1' ? '' : 'S'} TO GO',
              style: TextStyle(
                fontSize: 150,
                fontWeight: FontWeight.w500,
                shadows: <Shadow>[
                  Shadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.25),
                  ),
                ],
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
