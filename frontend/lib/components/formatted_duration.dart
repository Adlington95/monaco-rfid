import 'package:flutter/material.dart';

class FormattedDuration extends StatelessWidget {
  const FormattedDuration(
    this.elapsed, {
    super.key,
    required this.style,
  });

  final Duration elapsed;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}:${elapsed.inMilliseconds.remainder(1000).toString().padLeft(3, '0')}',
      style: style.apply(fontFeatures: const [FontFeature.tabularFigures()]),
    );
  }
}

class FormattedGap extends StatelessWidget {
  const FormattedGap(
    this.elapsed, {
    super.key,
    required this.style,
  });

  final Duration elapsed;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (elapsed.inMinutes > 1) {
      return Text(
        '+${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}.${elapsed.inMilliseconds.remainder(1000).toString().padLeft(3, '0')}',
        style: style.apply(fontFeatures: const [FontFeature.tabularFigures()]),
      );
    }
    return Text(
      '+${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}.${elapsed.inMilliseconds.remainder(1000).toString().padLeft(3, '0')}',
      style: style.apply(fontFeatures: const [FontFeature.tabularFigures()]),
    );
  }
}
