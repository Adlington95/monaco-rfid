import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class ResetTimer extends StatefulWidget {
  const ResetTimer({super.key, required this.onFinish});

  final VoidCallback onFinish;
  @override
  State<ResetTimer> createState() => ResetTimerState();
}

class ResetTimerState extends State<ResetTimer> {
  Timer? _timer;

  int _elapsedMilliseconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsedMilliseconds += 100;
      });
      if (_elapsedMilliseconds >= 60000) {
        timer.cancel();
        if (mounted) {
          widget.onFinish();
          // context.go(ScanIdPage.name);
        }
      }
    });
  }

  void resetTimer() {
    setState(() {
      _elapsedMilliseconds = 0;
    });
    _timer?.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.white)),
      child: ZetaProgressBar.standard(
        isThin: true,
        label: '',
        progress: _elapsedMilliseconds / 60000,
        rounded: false,
      ),
    );
  }
}
