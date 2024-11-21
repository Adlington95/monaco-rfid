import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.index,
    this.child,
    this.highlighted = false,
    this.isPurple = false,
  });

  final int index;
  final Widget? child;
  final bool highlighted;
  final bool isPurple;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Stack(
        children: [
          if (highlighted)
            Positioned.fill(
              child: Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.grey.shade500,
                child: const ColoredBox(color: Colors.white),
              ),
            ),
          _RowContents(highlighted: highlighted, index: index, isPurple: isPurple, child: child),
        ],
      ),
    );
  }
}

class _RowContents extends StatelessWidget {
  const _RowContents({
    required this.highlighted,
    required this.index,
    required this.child,
    required this.isPurple,
  });

  final bool highlighted;
  final int index;
  final Widget? child;
  final bool isPurple;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: Durations.medium2,
          height: 42,
          width: 70,
          color: highlighted
              ? null
              : isPurple
                  ? Zeta.of(context).colors.purple
                  : Zeta.of(context).colors.textDefault,
          child: Center(
            child: Text(
              index.toString(),
              style: TextStyle(
                color: highlighted ? Zeta.of(context).colors.textDefault : Colors.white,
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
            color: highlighted ? null : Zeta.of(context).colors.textSubtle.withOpacity(0.5),
            child: child == null
                ? const Nothing()
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: highlighted ? FontWeight.w600 : FontWeight.w300,
                        fontFamily: 'Titillium',
                        color: highlighted ? Zeta.of(context).colors.textDefault : Colors.white,
                      ),
                      child: child!,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
