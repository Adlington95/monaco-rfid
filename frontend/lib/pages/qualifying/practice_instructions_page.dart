import 'package:flutter/material.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';

class PracticeInstructionsPage extends StatelessWidget {
  const PracticeInstructionsPage({super.key});
  static const name = '/practiceInstructionsPage';

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      shadows: <Shadow>[
        Shadow(
          offset: const Offset(0, 4),
          blurRadius: 4,
          color: Colors.black.withOpacity(0.25),
        ),
      ],
      fontSize: 64,
      fontWeight: FontWeight.w800,
      height: 1.5,
      color: Colors.white,
    );

    return GestureDetector(
      onTap: Provider.of<GameState>(context).isEmulator
          ? () => Provider.of<WebSocketState>(context, listen: false).addMessage('{"lapTimes": [60000]}')
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(340, 180, 340, 140),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'You get ${context.read<GameState>().settings.practiceLaps} practice laps',
              style: textStyle,
            ),
            Text(
              'After, you will go straight into',
              style: textStyle.copyWith(fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            Text('${context.read<GameState>().settings.qualifyingLaps} qualifying laps', style: textStyle),
          ],
        ),
      ),
    );
  }
}
