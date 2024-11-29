import 'package:flutter/material.dart';
import 'package:frontend/components/lap_counter.dart';
import 'package:frontend/components/leaderboard.dart';
import 'package:frontend/components/reset_timer.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class QualifyingFinishPage extends StatelessWidget {
  const QualifyingFinishPage({super.key});
  static const name = '/qualifyingFinish';
  @override
  Widget build(BuildContext context) {
    final resetTimerKey = GlobalKey<ResetTimerState>();

    return Consumer<WebSocketState>(
      builder: (context, state, child) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: GestureDetector(
                      onTap: () => resetTimerKey.currentState?.resetTimer(),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FINISH',
                                  style: TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Expanded(child: LapCounter()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(48, 0, 68, 0),
                      child: GestureDetector(
                        onTap: () => context.go(LeaderBoardsPage.name),
                        child: const Leaderboard(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Positioned(
            //   bottom: 0,
            //   width: MediaQuery.of(context).size.width,
            //   child: ResetTimer(
            //     key: resetTimerKey,
            //     onFinish: () => context.go(LeaderBoardsPage.name),
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
