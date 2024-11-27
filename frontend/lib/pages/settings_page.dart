import 'package:flutter/material.dart';
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
                    subtitle: TextFormField(
                      onSaved: (value) => value != null ? state.serverUrl = value : null,
                      initialValue: state.serverUrl,
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
                    subtitle: TextFormField(
                      onSaved: (value) => value != null ? state.restPort = value : null,
                      initialValue: state.restPort,
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
                    subtitle: TextFormField(
                      onSaved: (value) => value != null ? state.websocketPort = value : null,
                      initialValue: state.websocketPort,
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
                  ),
                  const SizedBox(height: 40),
                  ListTile(
                    leading: const Icon(
                      Icons.track_changes,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Track length',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: TextFormField(
                      onSaved: (value) =>
                          value != null ? state.circuitLength = double.tryParse(value) ?? state.circuitLength : null,
                      initialValue: state.circuitLength.toString(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  ),
                  const SizedBox(height: 40),
                  ListTile(
                    leading: const Icon(
                      Icons.time_to_leave,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Practice laps',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: TextFormField(
                      onSaved: (value) =>
                          value != null ? state.practiceLaps = int.tryParse(value) ?? state.practiceLaps : null,
                      initialValue: state.practiceLaps.toString(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  ),
                  const SizedBox(height: 40),
                  ListTile(
                    leading: const Icon(
                      Icons.timelapse,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Qualifying laps',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: TextFormField(
                      onSaved: (value) =>
                          value != null ? state.qualifyingLaps = int.tryParse(value) ?? state.qualifyingLaps : null,
                      initialValue: state.qualifyingLaps.toString(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  ),
                  const SizedBox(height: 40),
                  ListTile(
                    leading: const Icon(
                      Icons.car_crash,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Race laps',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: TextFormField(
                      onSaved: (value) => value != null ? state.raceLaps = int.tryParse(value) ?? state.raceLaps : null,
                      initialValue: state.raceLaps.toString(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  ),
                  const SizedBox(height: 40),

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
                                context.go(CarStartPage.name);
                              case 'pc':
                                context.go(PracticeCountdownPage.name);
                                break;
                              case 'q':
                                context.go(QualifyingPage.name);
                                break;
                              case 'f':
                                context.go(FinishPage.name);
                                break;
                              default:
                                break;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        await Restart.restartApp();
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
