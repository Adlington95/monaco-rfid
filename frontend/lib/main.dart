import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterfrontend/pages/car_start.dart';
import 'package:flutterfrontend/pages/leaderboards.dart';
import 'package:flutterfrontend/pages/practice_coutdown.dart';
import 'package:flutterfrontend/pages/practice_instructions.dart';
import 'package:flutterfrontend/pages/qualifying.dart';
import 'package:flutterfrontend/pages/scan_id.dart';
import 'package:flutterfrontend/state/dw_state.dart';
import 'package:flutterfrontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

void main() => runApp(const MyApp());

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => kDebugMode ? LeaderBoardsPage.name : ScanIdPage.name,
      builder: (context, state) => const LeaderBoardsPage(),
    ),
    GoRoute(
      path: LeaderBoardsPage.name,
      builder: (context, state) => const LeaderBoardsPage(),
    ),
    GoRoute(
      path: ScanIdPage.name,
      builder: (context, state) => const ScanIdPage(),
    ),
    GoRoute(
      path: PracticeInstructionsPage.name,
      builder: (context, state) => const PracticeInstructionsPage(),
    ),
    GoRoute(
      path: CarStartPage.name,
      builder: (context, state) => const CarStartPage(),
    ),
    GoRoute(
      path: PracticeCountdownPage.name,
      builder: (context, state) => const PracticeCountdownPage(),
    ),
    GoRoute(
      path: QualifyingPage.name,
      builder: (context, state) => const QualifyingPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WebSocketState()),
        ChangeNotifierProvider(create: (context) => DataWedgeState()),
      ],
      child: ZetaProvider.base(
        initialThemeMode: ThemeMode.light,
        builder: (context, light, dark, themeMode) => MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'F1',
            colorScheme: const ColorScheme.dark(),
          ),
          builder: (_, child) => Builder(builder: (context2) {
            return ColoredBox(
              color: light.colorScheme.textSubtle,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: -260,
                    child: SvgPicture.asset(
                      'lib/assets/zebrahead.svg',
                      height: 1460,
                    ),
                  ),
                  Scaffold(
                    body: child,
                    backgroundColor: Colors.transparent,
                  ),
                  Positioned(
                    right: 40,
                    top: 40,
                    child: IconButton(
                      icon: const Icon(ZetaIcons.restart_alt),
                      iconSize: 60,
                      onPressed: () {
                        Provider.of<DataWedgeState>(context, listen: false).clear();
                        router.go(kDebugMode ? '/' : ScanIdPage.name);
                      },
                    ),
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
