import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/components/lap_counter.dart';
import 'package:frontend/components/leaderboard.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/pages/scan_id_page.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class FinishPage extends StatefulWidget {
  const FinishPage({super.key});
  static const name = '/finish';

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  Timer? _timer;
  int _elapsedMilliseconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsedMilliseconds += 100;
      });
      if (_elapsedMilliseconds >= 60000) {
        timer.cancel();
        if (mounted) {
          context.go(ScanIdPage.name);
        }
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _elapsedMilliseconds = 0;
    });
    _timer?.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _resetTimer,
                            child: const Column(
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
                                LapCounter(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(48, 0, 68, 0),
                      child: GestureDetector(
                        onTap:
                            Provider.of<GameState>(context).isEmulator ? () => context.go(LeaderBoardsPage.name) : null,
                        child: const Leaderboard(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: ZetaProgressBar(
                isThin: true,
                label: '',
                progress: _elapsedMilliseconds / 60000,
                type: ZetaProgressBarType.standard,
                rounded: false,
              ),
            ),
          ],
        );
      },
    );
  }
}
