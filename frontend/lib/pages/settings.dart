import 'package:flutter/material.dart';
import 'package:frontend/state/game_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/generated/icons/icons.g.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  static const String name = '/settings';

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) => ListView(
        children: [
          ListTile(
            leading: const Icon(ZetaIcons.upload),
            title: const Text('Load Config from JSON'),
            onTap: state.applyFromJson,
          ),
          //TODO: Getting an error from file picker package
          ListTile(
            leading: const Icon(ZetaIcons.download),
            title: const Text('Save config to JSON'),
            onTap: state.saveToJson,
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacy'),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              // Navigate to help & support
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Navigate to about page
            },
          ),
        ],
      ),
    );
  }
}
