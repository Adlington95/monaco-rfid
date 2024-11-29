import 'package:flutter/material.dart';
import 'package:frontend/components/id_card.dart';
import 'package:frontend/models/scan_user_body.dart';
import 'package:frontend/models/status.dart';
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
      child: context.watch<RestState>().status == Status.UNKNOWN && !Provider.of<GameState>(context).isEmulator
          ? const Text('Unable to connect to server')
          : IdCard(
              title: gameState.loggedInUser != null
                  ? 'Welcome'
                  : 'Scan your ${context.read<GameState>().scannedThingName} below',
              onTap: Provider.of<GameState>(context).isEmulator
                  ? () => context.read<RestState>().postUser(ScanUserBody('marciltdon', 'marcildon'))
                  // ? () => context.read<RestState>().postUser(ScanUserBody('marcilton', 'marcilton'))
                  : gameState.loggedInUser == null
                      ? context.read<DataWedgeState>().scanBarcode
                      : null,
              data: gameState.loggedInUser,
            ),
    );
  }
}
