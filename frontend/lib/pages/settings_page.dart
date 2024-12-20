import 'package:file_picker/file_picker.dart';
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
import 'package:zeta_flutter/zeta_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.settings});
  static const String name = '/settings';

  final GameSettings? settings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
      child: _SettingsPageBody(settings: settings ?? context.read<GameState>().settings),
    );
  }
}

class _SettingsPageBody extends StatefulWidget {
  const _SettingsPageBody({required this.settings});

  final GameSettings settings;
  @override
  State<_SettingsPageBody> createState() => _SettingsPageBodyState();
}

class _SettingsPageBodyState extends State<_SettingsPageBody> {
  final _formKey = GlobalKey<FormState>();
  late GameSettings settings;

  @override
  void initState() {
    super.initState();
    settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, _) {
        return Builder(
          builder: (context) {
            return Column(
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
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(circuitLength: double.tryParse(value));
                                        }
                                      },
                                      initialValue: settings.circuitLength.toString(),
                                      title: 'Track length',
                                      icon: Icons.timeline,
                                      numeric: true,
                                    ),
                                    SettingRow(
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(practiceLaps: int.tryParse(value));
                                        }
                                      },
                                      initialValue: settings.practiceLaps.toString(),
                                      title: 'Practice laps',
                                      icon: Icons.time_to_leave,
                                      numeric: true,
                                    ),
                                    SettingRow(
                                      icon: Icons.timelapse,
                                      title: 'Qualifying laps',
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(qualifyingLaps: int.tryParse(value));
                                        }
                                      },
                                      initialValue: settings.qualifyingLaps.toString(),
                                      numeric: true,
                                    ),
                                    SettingRow(
                                      icon: Icons.car_crash,
                                      title: 'Race laps',
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(raceLaps: int.tryParse(value));
                                        }
                                      },
                                      initialValue: settings.raceLaps.toString(),
                                      numeric: true,
                                    ),
                                    SettingRow(
                                      icon: Icons.lightbulb,
                                      title: 'Race light amount',
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(raceLights: int.tryParse(value));
                                        }
                                      },
                                      initialValue: settings.raceLights.toString(),
                                      numeric: true,
                                    ),
                                    SettingRow(
                                      icon: Icons.lightbulb,
                                      title: 'Scanned thing name',
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(scannedThingName: value);
                                        }
                                      },
                                      initialValue: settings.scannedThingName,
                                    ),
                                    SettingRow(
                                      icon: Icons.lightbulb,
                                      title: 'Event name',
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(eventName: value);
                                        }
                                      },
                                      initialValue: settings.eventName,
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
                                    SettingRow(
                                      icon: ZetaIcons.uhf_rfid,
                                      initialValue: settings.rfidReaderUrl,
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(rfidReaderUrl: value);
                                        }
                                      },
                                      title: 'RFID Reader IP address',
                                    ),
                                    SettingRow(
                                      icon: Icons.https,
                                      title: 'Server IP address',
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(serverUrl: value);
                                        }
                                      },
                                      initialValue: settings.serverUrl,
                                    ),
                                    SettingRow(
                                      icon: Icons.api,
                                      title: 'Rest port',
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(restPort: value);
                                        }
                                      },
                                      initialValue: settings.restPort,
                                      numeric: true,
                                    ),
                                    SettingRow(
                                      initialValue: settings.websocketPort,
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(websocketPort: value);
                                        }
                                      },
                                      title: 'WebSocket port',
                                      icon: Icons.web_asset,
                                    ),
                                    SettingRow(
                                      initialValue: settings.minLapTime.toString(),
                                      onSaved: (value) {
                                        if (value != null) {
                                          settings = settings.copyWith(minLapTime: int.tryParse(value));
                                        }
                                      },
                                      numeric: true,
                                      title: 'Minimum lap time (in seconds)',
                                      icon: Icons.timer,
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
                                                  context.go(QualifyingLoginPage.name);
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
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'Tools',
                                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                ZetaButton(
                                  label: 'RFID Reset',
                                  onPressed: context.watch<RestState>().rfidResetting
                                      ? null
                                      : () async {
                                          await context.read<RestState>().resetRFID();
                                        },
                                ),
                                ZetaButton(
                                  label: 'Save settings to JSON',
                                  onPressed: () async {
                                    _formKey.currentState?.save();
                                    state.settings = settings;
                                    await state.writeJson(settings);
                                  },
                                ),
                                ZetaButton(
                                  label: 'Load settings from JSON',
                                  onPressed: () async {
                                    final newSettings = await GameSettings.fromJson();
                                    if (newSettings != null) {
                                      if (context.mounted) {
                                        context.pushReplacement(SettingsPage.name, extra: newSettings);
                                      }
                                    }
                                  },
                                ),
                                ZetaButton(
                                  label: 'Set background image',
                                  onPressed: () {
                                    FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['jpg', 'jpeg', 'png'],
                                    ).then((value) {
                                      if (value != null) {
                                        setState(
                                          () => settings = settings.copyWith(backgroundImage: value.files.single.path),
                                        );
                                      }
                                    });
                                  },
                                ),
                                ZetaButton(
                                  label: 'Clear background image',
                                  onPressed: () => setState(() => settings = settings.copyWith(backgroundImage: '')),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (settings != state.settings) ...[
                        const Text(
                          'Unsaved changes',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(width: 20),
                      ],
                      ZetaButton(
                        label: 'Cancel',
                        onPressed: () async {
                          if (context.mounted) context.pushReplacement(LeaderBoardsPage.name);
                        },
                      ),
                      ZetaButton(
                        label: 'Save',
                        onPressed: () async {
                          _formKey.currentState?.save();
                          state.settings = settings;
                          await state.settings.toSavedPreferences();
                          if (context.mounted) context.pushReplacement(LeaderBoardsPage.name);
                        },
                      ),
                    ].gap(40),
                  ),
                ),
              ],
            );
          },
        );
      },
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
