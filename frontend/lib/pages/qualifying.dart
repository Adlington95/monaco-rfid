import 'package:flutter/material.dart';

class QualifyingPage extends StatelessWidget {
  static const name = '/qualifying';

  const QualifyingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 15,
          child: Container(
            color: Colors.blue,
          ),
        ),
        Flexible(
          flex: 13,
          child: Container(
            color: Colors.red,
          ),
        )
      ],
    );
  }
}
