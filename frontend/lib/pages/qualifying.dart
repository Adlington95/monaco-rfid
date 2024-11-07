import 'package:flutter/material.dart';
import 'package:flutterfrontend/components/card.dart';
import 'package:flutterfrontend/state/ws_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class QualifyingPage extends StatelessWidget {
  static const name = '/qualifying';

  const QualifyingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Row(
              children: [
                Expanded(
                  child: TranslucentCard(
                      child: Padding(
                    padding: const EdgeInsets.all(24).copyWith(right: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('LAP TIMES', style: TextStyle(fontSize: 40)),
                        ...List.generate(10, (index) => RowItem(index: index + 1))
                      ].gap(12),
                    ),
                  )),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: TranslucentCard(
                  child: Column(
                children: [Text('Lap Times', style: TextStyle(fontSize: 40))],
              )),
            ),
          )
        ],
      ),
    );
  }
}

class RowItem extends StatelessWidget {
  const RowItem({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(builder: (context, state, child) {
      final String time = state.lapTime(index);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      time,
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w300, fontFamily: 'Titillium'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
