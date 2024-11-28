import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/state/dw_state.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';

class QualifyingStartPage extends StatefulWidget {
  const QualifyingStartPage({super.key});
  static const String name = '/qualifyingStartPage';

  @override
  State<QualifyingStartPage> createState() => _QualifyingStartPageState();
}

class _QualifyingStartPageState extends State<QualifyingStartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      Provider.of<DataWedgeState>(context, listen: false).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketState>(
      builder: (context, state, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 990,
                child: Text(
                  'Place your car on the START',
                  style: TextStyle(
                    fontSize: 82,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: Provider.of<GameState>(context).isEmulator ? () => state.addMessage('{"connected":true}') : null,
                child: SvgPicture.asset('assets/car.svg', width: 200, height: 200),
              ),
            ],
          ),
        );
      },
    );
  }
}
