import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterfrontend/state/ws_state.dart';
import 'package:provider/provider.dart';

class PracticeCountdownPage extends StatelessWidget {
  const PracticeCountdownPage({super.key});
  static const name = '/practice-countdown';

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, child) => GestureDetector(
        onTap:
            kDebugMode ? () => state.addMessage('[100000,20000${state.lapTimes.length == 2 ? ',200000' : ''}]') : null,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(60),
            child: Text(
              '${state.practiceLapsRemaining} PRACTICE LAP${state.practiceLapsRemaining == 1 ? '' : 'S'} TO GO',
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
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
