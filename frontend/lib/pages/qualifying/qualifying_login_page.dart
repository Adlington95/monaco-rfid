import 'package:flutter/material.dart';
import 'package:frontend/components/id_card.dart';
import 'package:frontend/models/scan_user_body.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/pages/qualifying/qualifying_start_page.dart';
import 'package:frontend/state/dw_state.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class QualifyingLoginPage extends StatefulWidget {
  const QualifyingLoginPage({super.key});
  static const name = '/qualifyingLogin';

  @override
  State<QualifyingLoginPage> createState() => _QualifyingLoginPageState();
}

class _QualifyingLoginPageState extends State<QualifyingLoginPage> {
  final isChangingPage = false;

  Future<void> changePage() async {
    if (isChangingPage) return;
    await Future<void>.delayed(const Duration(seconds: 2));
    if (context.mounted && mounted) context.pushReplacement(QualifyingStartPage.name);
  }

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
    if (gameState.loggedInUser != null && wsState.connected && !isChangingPage) {
      changePage();
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => context.read<DataWedgeState>().clear(),
      child: context.watch<RestState>().status == Status.UNKNOWN && !Provider.of<GameState>(context).isEmulator
          ? const Text('Unable to connect to server')
          : IdCard(
              title: gameState.loggedInUser != null
                  ? 'Welcome'
                  : 'Scan your ${context.read<GameState>().scannedThingName} below',
              onTap: gameState.loggedInUser != null
                  ? () => context.go(QualifyingStartPage.name)
                  : Provider.of<GameState>(context).isEmulator
                      ? () => context
                          .read<RestState>()
                          .postUser(ScanUserBody('marc', 'ilton', 'ingerland', 'marc@linton.com'))
                      : context.read<DataWedgeState>().scanBarcode,
              data: gameState.loggedInUser,
            ),
    );
  }
}
