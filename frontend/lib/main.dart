import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/models/status.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/pages/qualifying/practice_coutdown_page.dart';
import 'package:frontend/pages/qualifying/practice_instructions_page.dart';
import 'package:frontend/pages/qualifying/qualifying_finish_page.dart';
import 'package:frontend/pages/qualifying/qualifying_login_page.dart';
import 'package:frontend/pages/qualifying/qualifying_page.dart';
import 'package:frontend/pages/qualifying/qualifying_start_page.dart';
import 'package:frontend/pages/race/race_countdown_page.dart';
import 'package:frontend/pages/race/race_finish_page.dart';
import 'package:frontend/pages/race/race_instructions_page.dart';
import 'package:frontend/pages/race/race_login_page.dart';
import 'package:frontend/pages/race/race_page.dart';
import 'package:frontend/pages/race/race_start_page.dart';
import 'package:frontend/pages/settings_page.dart';
import 'package:frontend/state/dw_state.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:frontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

Key key = UniqueKey();
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

  runApp(MyApp(state: state, key: key));
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
            'assets/zebrahead.svg',
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
          child: IconButton(
            onPressed: () => context.pushReplacement(LeaderBoardsPage.name),
            icon: const Icon(ZetaIcons.restart_alt),
            color: Colors.white.withOpacity(0.8),
            iconSize: 60,
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
      // redirect: (context, state) => LeaderBoardsPage.name,
      // redirect: (context, state) => RacePage.name,
      // redirect: (context, state) => RaceFinishPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const LeaderBoardsPage()),
    ),
    GoRoute(
      path: LeaderBoardsPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const LeaderBoardsPage()),
    ),
    GoRoute(
      path: QualifyingLoginPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const QualifyingLoginPage()),
    ),
    GoRoute(
      path: PracticeInstructionsPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const PracticeInstructionsPage()),
    ),
    GoRoute(
      path: QualifyingStartPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const QualifyingStartPage()),
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
      path: QualifyingFinishPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const QualifyingFinishPage()),
    ),
    GoRoute(
      path: SettingsPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const SettingsPage()),
    ),
    GoRoute(
      path: RaceLoginPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const RaceLoginPage()),
    ),
    GoRoute(
      path: RaceStartPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const RaceStartPage()),
    ),
    GoRoute(
      path: RaceCountdownPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const RaceCountdownPage()),
    ),
    GoRoute(
      path: RacePage.name,
      pageBuilder: (context, state) => wrapper(context, state, const RacePage()),
    ),
    GoRoute(
      path: RaceFinishPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const RaceFinishPage()),
    ),
    GoRoute(
      path: RaceInstructionsPage.name,
      pageBuilder: (context, state) => wrapper(context, state, const RaceInstructionsPage()),
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
          theme: ThemeData(
            fontFamily: 'F1',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(),
              bodyMedium: TextStyle(),
              bodySmall: TextStyle(),
            ).apply(bodyColor: Colors.white),
          ),
          builder: (_, child) => Scaffold(body: child ?? const Nothing()),
        ),
      ),
    );
  }
}
