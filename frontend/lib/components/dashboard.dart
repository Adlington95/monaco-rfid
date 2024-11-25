import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frontend/components/formatted_duration.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const large = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 80,
      height: 1.2,
      fontFamily: 'Titillium',
      color: Colors.white,
    );
    const small = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 22,
      height: 1,
      fontFamily: 'Titillium',
      color: Colors.white,
    );

    return Consumer<WebSocketState>(
      builder: (context, state, child) => SizedBox(
        height: 400,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: CustomPaint(
            painter: CurvePainter(isChild: false),
            child: CustomPaint(
              painter: CurvePainter(isChild: true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Circle(
                    children: [
                      FittedBox(child: Stopwatch(initialDuration: state.startTime, style: large)),
                      const Text('Total Time', style: small),
                    ],
                  ),
                  Circle(
                    children: [
                      const Text('Speed'),
                      FittedBox(
                        child: Text(state.averageSpeed == 0 ? '' : state.averageSpeed.toStringAsFixed(3), style: large),
                      ),
                      const Text('m/s', style: small),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Circle extends StatelessWidget {
  const Circle({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, const ZetaPrimitivesLight().warm.shade70],
          ),
          width: 2,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  CurvePainter({required this.isChild});
  final bool isChild;

  @override
  void paint(Canvas canvas, Size size) {
    final height = isChild ? 0.18 : 0.12;
    const colors = ZetaPrimitivesLight();

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(isChild ? 0 : size.width, isChild ? size.height : 0),
        [
          if (isChild) colors.warm.shade80 else Colors.grey,
          if (isChild) colors.warm.shade100 else Colors.white,
          if (isChild) colors.warm.shade80 else Colors.grey,
        ],
        [0, 0.5, 1],
      )
      ..style = PaintingStyle.fill;

    // TODO: Make this rounded
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * height)
      ..quadraticBezierTo(size.width / 2, 1 / (size.height * height), size.width, size.height * height)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..moveTo(0, size.height * 0.18);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class GradientBoxBorder extends BoxBorder {
  const GradientBoxBorder({
    required this.gradient,
    this.width = 1.0,
  });
  final Gradient gradient;
  final double width;

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (shape == BoxShape.rectangle) {
      if (borderRadius != null) {
        _paintRRect(canvas, rect, borderRadius);
      } else {
        _paintRect(canvas, rect);
      }
    } else {
      _paintCircle(canvas, rect);
    }
  }

  void _paintRect(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  void _paintRRect(Canvas canvas, Rect rect, BorderRadius borderRadius) {
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );
    canvas.drawRRect(rrect, paint);
  }

  void _paintCircle(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}

class Stopwatch extends StatefulWidget {
  const Stopwatch({super.key, required this.initialDuration, required this.style});
  final DateTime initialDuration;
  final TextStyle style;
  @override
  State<Stopwatch> createState() => _StopwatchState();
}

class _StopwatchState extends State<Stopwatch> with SingleTickerProviderStateMixin {
  Duration elapsed = Duration.zero;

  late final Ticker ticker;
  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      elapsed = DateTime.now().difference(widget.initialDuration);
      ticker = createTicker((elapsed) => setState(() => this.elapsed = elapsed))..start();
    });
  }

  @override
  Widget build(BuildContext context) => FormattedDuration(elapsed, style: widget.style);
}
