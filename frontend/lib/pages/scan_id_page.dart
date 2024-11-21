import 'package:flutter/material.dart';
import 'package:frontend/components/id_card.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/pages/car_start_page.dart';
import 'package:frontend/state/dw_state.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';

class ScanIdPage extends StatefulWidget {
  const ScanIdPage({super.key});
  static const name = '/scan-id';

  @override
  State<ScanIdPage> createState() => _ScanIdPageState();
}

class _ScanIdPageState extends State<ScanIdPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataWedgeState>().initScanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final wsState = context.read<WebSocketState>();

    if (gameState.loggedInUser != null && !wsState.connected) {
      wsState.connect();
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => context.read<DataWedgeState>().clear(),
      child: context.watch<RestState>().status == Status.UNKNOWN
          ? const Text('Unable to connect to server')
          : IdCard(
              title: gameState.loggedInUser != null ? 'Welcome' : 'Scan your ID card below',
              onTap: gameState.loggedInUser != null
                  ? () => router.pushReplacement(CarStartPage.name, extra: gameState.loggedInUser)
                  : context.read<DataWedgeState>().scanBarcode,
              data: gameState.loggedInUser,
            ),
    );
  }
}
