import 'package:flutter/material.dart';
import 'package:frontend/components/formatted_duration.dart';
import 'package:frontend/components/lap_counter.dart';
import 'package:frontend/components/live_timing.dart';
import 'package:frontend/pages/qualifying/finish_page.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class QualifyingPage extends StatelessWidget {
  const QualifyingPage({super.key});
  static const name = '/qualifying';

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, child) {
        return Row(
          children: [
            Expanded(
              flex: 6,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: Provider.of<GameState>(context).isEmulator ? () => context.go(FinishPage.name) : null,
                      child: const LapCounter(),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 7,
              child: LiveTiming(),
            ),
          ],
        );
      },
    );
  }
}

class RowItem extends StatelessWidget {
  const RowItem({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, child) {
        final time = state.qualifyingLapTime(index);
        return Row(
          children: [
            Container(
              height: 52,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                color: Zeta.of(context).colors.textDefault,
              ),
              child: Center(
                child: Text(
                  index.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Titillium',
                    height: 1,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Zeta.of(context).colors.textSubtle.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                ),
                child: time == ''
                    ? const Nothing()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: FormattedDuration(
                              Duration(milliseconds: double.parse(time).toInt()),
                              style:
                                  const TextStyle(fontSize: 30, fontWeight: FontWeight.w300, fontFamily: 'Titillium'),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
