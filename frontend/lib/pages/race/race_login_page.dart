import 'package:flutter/material.dart';
import 'package:frontend/components/id_card.dart';
import 'package:frontend/models/scan_user_body.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/state/dw_state.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:provider/provider.dart';

class RaceLoginPage extends StatefulWidget {
  const RaceLoginPage({super.key});
  static const name = '/raceLoginPage';

  @override
  State<RaceLoginPage> createState() => _RaceLoginPageState();
}

class _RaceLoginPageState extends State<RaceLoginPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<GameState>().racers.isEmpty) {
        context.read<RestState>()
          ..clear()
          ..resetStatus(status: Status.RACE);

        context.read<DataWedgeState>()
          ..clear()
          ..initScanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.all(100),
          child: Column(
            children: [
              const GameTitle(),
              const SizedBox(height: 20),
              Box(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IdCard(
                      onTap: state.isEmulator
                          ? () {
                              context.read<RestState>().postUser(ScanUserBody('Luke ', ' Walton', 'uk', 'email'));
                            }
                          : null,
                      data: state.racers.isNotEmpty ? state.racers[0] : null,
                      heroId: 'racer1',
                    ),
                    IdCard(
                      onTap: state.isEmulator
                          ? () {
                              context
                                  .read<RestState>()
                                  .postUser(ScanUserBody('Marcilton', 'Marcilton', 'ingerland', 'email2'));
                            }
                          : null,
                      data: state.racers.length > 1 ? state.racers[1] : null,
                      heroId: 'racer2',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
