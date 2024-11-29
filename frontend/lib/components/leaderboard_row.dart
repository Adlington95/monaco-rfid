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
  });

  final int index;
  final Widget? child;
  final Color? highlightColor;
  final Color? leadingColor;

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
          Row(
            children: [
              AnimatedContainer(
                duration: Durations.medium2,
                height: 42,
                width: 70,
                color: highlightColor != null ? null : leadingColor ?? Zeta.of(context).colors.textDefault,
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
          ),
        ],
      ),
    );
  }
}
