import 'package:flutter/material.dart';
import 'package:frontend/components/lap_counter.dart';
import 'package:frontend/components/leaderboard.dart';
import 'package:frontend/pages/leaderboards.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class FinishPage extends StatelessWidget {
  const FinishPage({super.key});
  static const name = '/finish';

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, child) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Expanded(
                flex: 6,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FINISH',
                            style: TextStyle(fontSize: 80, fontWeight: FontWeight.w500),
                          ),
                          LapCounter(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Leaderboard(),
                      ),
                    ),
                    ZetaButton(
                      label: 'Next',
                      size: ZetaWidgetSize.large,
                      onPressed: () => context.go(LeaderBoardsPage.name),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
