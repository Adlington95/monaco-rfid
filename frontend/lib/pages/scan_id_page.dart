import 'package:flutter/material.dart';
import 'package:frontend/components/id_card.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/pages/car_start_page.dart';
import 'package:frontend/pages/practice_coutdown_page.dart';
import 'package:frontend/state/dw_state.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
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

    return GestureDetector(
      onTap: Provider.of<GameState>(context).isEmulator ? () => context.go(PracticeCountdownPage.name) : null,
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) => context.read<DataWedgeState>().clear(),
        child: context.watch<RestState>().status == Status.UNKNOWN && !Provider.of<GameState>(context).isEmulator
            ? const Text('Unable to connect to server')
            : IdCard(
                title: gameState.loggedInUser != null ? 'Welcome' : 'Scan your ID card below',
                onTap: gameState.loggedInUser != null
                    ? () => router.pushReplacement(CarStartPage.name)
                    : context.read<DataWedgeState>().scanBarcode,
                data: gameState.loggedInUser,
              ),
      ),
    );
  }
}
