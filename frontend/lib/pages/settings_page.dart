import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/pages/qualifying/practice_coutdown_page.dart';
import 'package:frontend/pages/qualifying/practice_instructions_page.dart';
import 'package:frontend/pages/qualifying/qualifying_finish_page.dart';
import 'package:frontend/pages/qualifying/qualifying_login_page.dart';
import 'package:frontend/pages/qualifying/qualifying_page.dart';
import 'package:frontend/pages/qualifying/qualifying_start_page.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Game Play Settings',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              SettingRow(
                                onSaved: (value) => value != null
                                    ? state.circuitLength = double.tryParse(value) ?? state.circuitLength
                                    : null,
                                initialValue: state.circuitLength.toString(),
                                title: 'Track length',
                                icon: Icons.timeline,
                                numeric: true,
                              ),
                              SettingRow(
                                onSaved: (value) => value != null
                                    ? state.practiceLaps = int.tryParse(value) ?? state.practiceLaps
                                    : null,
                                initialValue: state.practiceLaps.toString(),
                                title: 'Practice laps',
                                icon: Icons.time_to_leave,
                                numeric: true,
                              ),
                              SettingRow(
                                icon: Icons.timelapse,
                                title: 'Qualifying laps',
                                onSaved: (value) => value != null
                                    ? state.qualifyingLaps = int.tryParse(value) ?? state.qualifyingLaps
                                    : null,
                                initialValue: state.qualifyingLaps.toString(),
                                numeric: true,
                              ),
                              SettingRow(
                                icon: Icons.car_crash,
                                title: 'Race laps',
                                onSaved: (value) =>
                                    value != null ? state.raceLaps = int.tryParse(value) ?? state.raceLaps : null,
                                initialValue: state.raceLaps.toString(),
                                numeric: true,
                              ),
                              SettingRow(
                                icon: Icons.lightbulb,
                                title: 'Race light amount',
                                onSaved: (value) =>
                                    value != null ? state.raceLights = int.tryParse(value) ?? state.raceLights : null,
                                initialValue: state.raceLights.toString(),
                                numeric: true,
                              ),
                              SettingRow(
                                icon: Icons.lightbulb,
                                title: 'Scanned thing name',
                                onSaved: (value) => value != null ? state.scannedThingName = value : null,
                                initialValue: state.scannedThingName,
                              ),
                            ].gap(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Technical Settings',
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Expanded(
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

                              SettingRow(
                                icon: Icons.https,
                                title: 'Server IP address',
                                onSaved: (value) => value != null ? state.serverUrl = value : null,
                                initialValue: state.serverUrl,
                              ),
                              SettingRow(
                                icon: Icons.api,
                                title: 'Rest port',
                                onSaved: (value) => value != null ? state.restPort = value : null,
                                initialValue: state.restPort,
                                numeric: true,
                              ),
                              SettingRow(
                                initialValue: state.websocketPort,
                                onSaved: (value) => value != null ? state.websocketPort = value : null,
                                title: 'WebSocket port',
                                icon: Icons.web_asset,
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                width: 200,
                                child: Row(
                                  children: [
                                    ZetaGroupButton.dropdown(
                                      label: 'Go to page',
                                      rounded: true,
                                      icon: Icons.find_in_page_rounded,
                                      items: [
                                        ZetaDropdownItem(label: 'Leaderboard Page', value: 'lp'),
                                        ZetaDropdownItem(label: 'Scan Id Page', value: 'si'),
                                        ZetaDropdownItem(label: 'Practice Instructions Page', value: 'pi'),
                                        ZetaDropdownItem(label: 'Car Start Page', value: 'cs'),
                                        ZetaDropdownItem(label: 'Practice Countdown Page', value: 'pc'),
                                        ZetaDropdownItem(label: 'Qualifying Page', value: 'q'),
                                        ZetaDropdownItem(label: 'Finish Page', value: 'f'),
                                      ],
                                      onChange: (item) {
                                        switch (item.value) {
                                          case 'lp':
                                            context.go(LeaderBoardsPage.name);
                                            break;
                                          case 'si':
                                            context.go(ScanIdPage.name);
                                            break;
                                          case 'pi':
                                            context.go(PracticeInstructionsPage.name);
                                            break;
                                          case 'cs':
                                            context.go(QualifyingStartPage.name);
                                          case 'pc':
                                            context.go(PracticeCountdownPage.name);
                                            break;
                                          case 'q':
                                            context.go(QualifyingPage.name);
                                            break;
                                          case 'f':
                                            context.go(QualifyingFinishPage.name);
                                            break;
                                          default:
                                            break;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ].gap(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: Nothing()),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ZetaButton(
                  label: 'RFID Reset',
                  onPressed: () async {
                    await context.read<RestState>().resetRFID();
                    if (mounted && context.mounted) context.pop();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ZetaButton(
                      label: 'Cancel',
                      onPressed: () => context.pop(),
                    ),
                    ZetaButton(
                      label: 'Save',
                      onPressed: () async {
                        _formKey.currentState?.save();
                        await state.saveToSharedPreferences();
                        key = UniqueKey();
                        if (context.mounted) context.pop();
                      },
                    ),
                  ].gap(40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.initialValue,
    required this.onSaved,
    required this.title,
    required this.icon,
    this.numeric = false,
  });
  final String initialValue;
  final FormFieldSetter<String> onSaved;
  final String title;
  final IconData icon;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: TextFormField(
        onSaved: onSaved,
        initialValue: initialValue,
        keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : null,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        cursorColor: Colors.blue,
      ),
    );
  }
}
