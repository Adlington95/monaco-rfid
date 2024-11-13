import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class User {
  User(
    this.name,
    this.previousAttempts,
    this.id,
    // this.company,
  );
  final String name;
  final int previousAttempts;
  final String id;
  // final String company;
}

class IdCard extends StatelessWidget {
  const IdCard({super.key, this.data, required this.title, this.onTap, required this.isLoading});

  final User? data;
  final String title;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // TODO: Animate this transition

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
          borderRadius: BorderRadius.circular(40),
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
                BoxShadow(color: Color(0x19000000), blurRadius: 58.88, offset: Offset(0, 29.44)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [Icon(ZetaIcons.barcode_qr_code, color: Colors.white, size: 62)],
                      ),
                      if (isLoading) ...[
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                      ] else if (data != null) ...[
                        Text(data!.name, style: const TextStyle(color: Colors.white, fontSize: 36)),
                        Text(
                          'Previous attempts: ${data!.previousAttempts}',
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ],
                    ].gap(40),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
