import 'package:flutter/material.dart';
import 'package:frontend/components/card.dart';
import 'package:frontend/pages/race/race_countdown_page.dart';
import 'package:go_router/go_router.dart';

class RaceInstructionsPage extends StatelessWidget {
  const RaceInstructionsPage({super.key});
  static const String name = '/raceInstructions';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Place your cars behind the START line',
            style: TextStyle(
              fontSize: 80,
              fontFamily: 'f1',
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const Hero(
            tag: 'raceInstructions',
            child: FittedBox(
              child: Text(
                "Don't go until all the lights are out",
                style: TextStyle(
                  fontSize: 80,
                  fontFamily: 'f1',
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
          TranslucentCard(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => context.go(RaceCountdownPage.name),
                child: const Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'READY',
                    style: TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
