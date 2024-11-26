import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class RaceStartPage extends StatelessWidget {
  const RaceStartPage({super.key});
  static const name = '/raceStartPage';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            context.read<GameState>().racers[context.read<WebSocketState>().raceCarIds.isEmpty ? 0 : 1].name,
            style: const TextStyle(
              fontSize: 110,
              fontFamily: 'f1',
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            'Place your car on the START',
            style: TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SvgPicture.asset('lib/assets/car.svg', width: 200, height: 200),
        ].gap(40),
      ),
    );
  }
}
