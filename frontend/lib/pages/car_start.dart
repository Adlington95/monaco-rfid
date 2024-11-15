import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/state/dw_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:provider/provider.dart';

class CarStartPage extends StatefulWidget {
  const CarStartPage({super.key});
  static const String name = '/car_start';

  @override
  State<CarStartPage> createState() => _CarStartPageState();
}

class _CarStartPageState extends State<CarStartPage> {
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
                onTap: debugMode ? () => state.addMessage('{"connected":true}') : null,
                child: SvgPicture.asset('lib/assets/car.svg', width: 200, height: 200),
              ),
            ],
          ),
        );
      },
    );
  }
}
