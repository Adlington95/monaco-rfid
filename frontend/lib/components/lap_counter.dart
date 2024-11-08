import 'package:flutter/material.dart';
import 'package:flutterfrontend/components/card.dart';
import 'package:flutterfrontend/components/formatted_duration.dart';
import 'package:flutterfrontend/state/ws_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class LapCounter extends StatelessWidget {
  const LapCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'lap-counter',
      child: TranslucentCard(
        child: Padding(
          padding: const EdgeInsets.all(24).copyWith(right: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LAP TIMES', style: TextStyle(fontSize: 40)),
              ...List.generate(10, (index) => RowItem(index: index + 1)),
            ].gap(12),
          ),
        ),
      ),
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

        return MyListIem(
          index: index,
          child: double.tryParse(time) != null
              ? FormattedDuration(
                  Duration(milliseconds: double.parse(time).toInt()),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300, fontFamily: 'Titillium'),
                )
              : const Nothing(),
        );
      },
    );
  }
}

class MyListIem extends StatelessWidget {
  const MyListIem({
    super.key,
    required this.index,
    this.child,
  });

  final int index;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 70,
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
            height: 42,
            decoration: BoxDecoration(
              color: Zeta.of(context).colors.textSubtle.withOpacity(0.5),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
            ),
            child: child == null
                ? const Nothing()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DefaultTextStyle(
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300, fontFamily: 'Titillium'),
                          child: child!,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
