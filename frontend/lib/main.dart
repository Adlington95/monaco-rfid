import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/pages/car_start_page.dart';
import 'package:frontend/pages/finish_page.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/pages/practice_coutdown_page.dart';
import 'package:frontend/pages/practice_instructions_page.dart';
import 'package:frontend/pages/qualifying_page.dart';
import 'package:frontend/pages/scan_id_page.dart';
import 'package:frontend/pages/settings_page.dart';
import 'package:frontend/state/dw_state.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

//TODO: Add a timer that returns to the main leaderboard screen if nothing happens for a minute

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  final GameState state;
  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    state = await GameState.loadFromPreferences(isEmulator: !deviceInfo.isPhysicalDevice);
  } else {
    state = await GameState.loadFromPreferences(isEmulator: true);
  }
  runApp(MyApp(state: state));
}

CustomTransitionPage<void> wrapper(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder:
        (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(opacity: CurveTween(curve: Curves.easeInOut).animate(animation), child: child);
    },
    child: Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: ColoredBox(color: Zeta.of(context).colors.black),
        ),
        Positioned(
          left: 0,
          top: -260,
          child: SvgPicture.asset(
            'lib/assets/zebrahead.svg',
            height: 1460,
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20,
          child: Scaffold(
            body: Center(child: child),
            backgroundColor: Colors.transparent,
          ),
        ),
        Positioned(
          left: 40,
          top: 40,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.watch<RestState>().status == Status.UNKNOWN ? Colors.red : Colors.green,
            ),
          ),
        ),
        Positioned(
          right: 40,
          top: 40,
          child: GestureDetector(
            onLongPress: () {
              Provider.of<DataWedgeState>(context, listen: false).clear();
              router.push(SettingsPage.name);
            },
            child: Icon(
              ZetaIcons.settings,
              color: Zeta.of(context).colors.textInverse.withOpacity(0.2),
              size: 60,
            ),
          ),
        ),
      ],
    ),
  );
}

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => LeaderBoardsPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const LeaderBoardsPage()),
    ),
    GoRoute(
      path: LeaderBoardsPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const LeaderBoardsPage()),
    ),
    GoRoute(
      path: ScanIdPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const ScanIdPage()),
    ),
    GoRoute(
      path: PracticeInstructionsPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const PracticeInstructionsPage()),
    ),
    GoRoute(
      path: CarStartPage.name,
      redirect: (context, state) => PracticeInstructionsPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const CarStartPage()),
    ),
    GoRoute(
      path: PracticeCountdownPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const PracticeCountdownPage()),
    ),
    GoRoute(
      path: QualifyingPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const QualifyingPage()),
    ),
    GoRoute(
      path: FinishPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const FinishPage()),
    ),
    GoRoute(
      path: SettingsPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const SettingsPage()),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.state});

  final GameState state;

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => state),
        ChangeNotifierProvider(create: (context) => RestState(gameState: state)),
        ChangeNotifierProxyProvider<RestState, DataWedgeState>(
          create: (context) =>
              DataWedgeState(gameState: state, restState: Provider.of<RestState>(context, listen: false)),
          update: (context, restState, dwState) => dwState ?? DataWedgeState(gameState: state, restState: restState),
        ),
        ChangeNotifierProxyProvider<RestState, WebSocketState>(
          create: (context) => WebSocketState(Provider.of<RestState>(context, listen: false)),
          update: (context, restState, wsState) => wsState ?? WebSocketState(restState),
        ),
      ],
      child: ZetaProvider.base(
        initialThemeMode: ThemeMode.light,
        builder: (context, light, dark, themeMode) => MaterialApp.router(
          routerConfig: router,
          key: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'F1'),
          builder: (_, child) => Scaffold(body: child ?? const Nothing()),
        ),
      ),
    );
  }
}
