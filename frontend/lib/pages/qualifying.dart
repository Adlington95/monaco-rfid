import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/components/card.dart';
import 'package:frontend/components/dashboard.dart';
import 'package:frontend/components/formatted_duration.dart';
import 'package:frontend/components/lap_counter.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/state/ws_state.dart';
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
                      onTap: debugMode
                          ? () => state.addMessage(
                                [
                                  ...state.lapTimes,
                                  (100000 +
                                          (100000 *
                                              (0.1 + 0.9 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)))
                                      .toInt(),
                                ].toString(),
                              )
                          : null,
                      child: const LapCounter(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TranslucentCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SvgPicture.asset('lib/assets/monaco.svg', height: 180),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(
                                    'LAP 1/10',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 48,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        'FASTEST LAP',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      FormattedDuration(
                                        Duration(milliseconds: state.fastestLap),
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Dashboard(),
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

class RowItem extends StatelessWidget {
  const RowItem({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, child) {
        final time = state.lapTime(index);
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
