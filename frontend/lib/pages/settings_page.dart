import 'package:flutter/material.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/state/game_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  static const String name = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) => Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // const ListTile(
                  //   leading: Icon(ZetaIcons.upload),
                  //   title: Text(
                  //     style: TextStyle(color: Colors.white),
                  //     'Load Config from JSON',
                  //   ),
                  //   // onTap: state.applyFromJson,
                  //   enabled: false,
                  // ),
                  // //TODO: Getting an error from file picker package
                  // const ListTile(
                  //   leading: Icon(ZetaIcons.download),
                  //   title: Text(
                  //     'Save config to JSON',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  //   // onTap: state.saveToJson,
                  //   enabled: false,
                  // ),

                  ListTile(
                    leading: const Icon(Icons.https, color: Colors.white),
                    title: const Text(style: TextStyle(color: Colors.white), 'Server IP address'),
                    subtitle: ZetaTextInput(
                      onSaved: (value) => value != null ? state.serverUrl = value : null,
                      initialValue: state.serverUrl,
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.api,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Rest port',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: ZetaTextInput(
                      onSaved: (value) => value != null ? state.restPort = value : null,
                      initialValue: state.restPort,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.web,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'WebSocket port',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: ZetaTextInput(
                      onSaved: (value) => value != null ? state.websocketPort = value : null,
                      initialValue: state.websocketPort,
                    ),
                  ),
                  ListTile(
                    title: const Text('Go to Leaderboard', style: TextStyle(color: Colors.white)),
                    onTap: () => context.go(LeaderBoardsPage.name),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ZetaButton(
                  label: 'Save',
                  onPressed: () async {
                    _formKey.currentState?.save();
                    await state.saveToSharedPreferences();
                    await Restart.restartApp();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}