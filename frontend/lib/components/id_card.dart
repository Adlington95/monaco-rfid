import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class User {
  final String name;
  final String company;
  final int previousAttempts;
  final String id;

  User(this.name, this.company, this.previousAttempts, this.id);
}

class IdCard extends StatelessWidget {
  const IdCard({super.key, this.data, required this.title, this.onTap});

  final User? data;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // TODO: Animate this transition

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 542,
        height: 250,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 82, fontWeight: FontWeight.w800),
        ),
      ),
      const SizedBox(height: 20),
      InkWell(
        borderRadius: BorderRadius.circular(40.0),
        onTap: onTap,
        child: Container(
          width: 542,
          height: 344,
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: const Alignment(0.93, -0.36),
              end: const Alignment(-0.93, 0.36),
              colors: [Colors.white.withOpacity(0.30000001192092896), Colors.white.withOpacity(0.05000000074505806)],
            ),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.47,
                color: Colors.white.withOpacity(0.30000001192092896),
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            shadows: const [
              BoxShadow(color: Color(0x19000000), blurRadius: 58.88, offset: Offset(0, 29.44), spreadRadius: 0)
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [Icon(ZetaIcons.barcode_qr_code, color: Colors.white, size: 62)],
                      ),
                      if (data != null) ...[
                        Text(data!.name, style: const TextStyle(color: Colors.white, fontSize: 36)),
                        Text(
                          'Previous attempts: ${data!.previousAttempts}',
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ]
                    ].gap(40)),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}