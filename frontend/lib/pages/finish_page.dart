import 'package:flutter/material.dart';
import 'package:frontend/components/lap_counter.dart';
import 'package:frontend/components/leaderboard.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';

class FinishPage extends StatefulWidget {
  const FinishPage({super.key});
  static const name = '/finish';

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  DateTime? popTime;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      popTime = DateTime.now().add(Duration(milliseconds: context.read<GameState>().finishPageDuration));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, child) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Row(
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
                          LapCounter(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(48, 0, 68, 0),
                  child: Leaderboard(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
