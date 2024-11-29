import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.index,
    this.child,
    this.highlightColor,
    this.leadingColor,
    this.isPurple = false,
    this.isGreen = false,
    this.isRed = false,
  });

  final int index;
  final Widget? child;
  final Color? highlightColor;
  final Color? leadingColor;

  final bool isPurple;
  final bool isGreen;
  final bool isRed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Stack(
        children: [
          if (highlightColor != null)
            Positioned.fill(
              child: Shimmer.fromColors(
                baseColor: highlightColor!,
                highlightColor: Colors.grey.shade500.blend(highlightColor!, 50),
                child: ColoredBox(color: highlightColor!),
              ),
            ),
          _RowContents(
            highlightColor: highlightColor,
            index: index,
            isPurple: isPurple,
            isRed: isRed,
            isGreen: isGreen,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _RowContents extends StatelessWidget {
  const _RowContents({
    required this.highlightColor,
    required this.index,
    required this.child,
    required this.isPurple,
    required this.isGreen,
    required this.isRed,
  });

  final Color? highlightColor;
  final int index;
  final Widget? child;
  final bool isPurple;
  final bool isGreen;
  final bool isRed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: Durations.medium2,
          height: 42,
          width: 70,
          color: highlightColor != null
              ? null
              : isRed
                  ? Zeta.of(context).colors.red
                  : isPurple
                      ? Zeta.of(context).colors.purple
                      : isGreen
                          ? Zeta.of(context).colors.green
                          : Zeta.of(context).colors.textDefault,
          child: Center(
            child: Text(
              index.toString(),
              style: TextStyle(
                color: highlightColor != null ? highlightColor!.onColor : Colors.white,
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
            color: highlightColor != null ? null : Zeta.of(context).colors.textSubtle.withOpacity(0.5),
            child: child == null
                ? const Nothing()
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: highlightColor != null ? FontWeight.w600 : FontWeight.w300,
                        fontFamily: 'Titillium',
                        color: highlightColor != null ? highlightColor!.onColor : Colors.white,
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
