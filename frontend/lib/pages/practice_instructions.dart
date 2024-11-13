import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';

class PracticeInstructionsPage extends StatelessWidget {
  const PracticeInstructionsPage({super.key});
  static const name = '/practice';

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
    );

    return GestureDetector(
      onTap: debugMode ? () => Provider.of<WebSocketState>(context, listen: false).addMessage('[60000]') : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(340, 180, 340, 140),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('You get 3 practice laps', style: textStyle),
            Text(
              'After, you will go straight into',
              style: textStyle.copyWith(fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            Text('10 qualifying laps', style: textStyle),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: PracticeInstructionsPage(),
    ),
  );
}
