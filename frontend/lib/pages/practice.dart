import 'package:flutter/material.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Laps'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You get 2 practice laps',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'After, you go straight into',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '10 qualifying laps',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PracticePage(),
  ));
}
