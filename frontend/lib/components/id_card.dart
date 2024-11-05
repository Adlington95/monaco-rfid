import 'package:flutter/material.dart';
import 'package:flutterfrontend/components/card.dart';
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
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 542,
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
        child: TranslucentCard(
          child: Container(
            width: 542,
            height: 344,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [Icon(ZetaIcons.barcode_qr_code, color: Colors.white, size: 62)],
                  ),
                  if (data != null) ...[
                    Text(data!.name, style: const TextStyle(color: Colors.white, fontSize: 36)),
                    // Text(data!.company, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    Text('Previous attempts: ${data!.previousAttempts}',
                        style: const TextStyle(color: Colors.white, fontSize: 24)),
                  ]
                ].gap(40)),
          ),
        ),
      ),
    ]);
  }
}
