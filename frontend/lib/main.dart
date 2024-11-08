import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterfrontend/pages/car_start.dart';
import 'package:flutterfrontend/pages/finish.dart';
import 'package:flutterfrontend/pages/leaderboards.dart';
import 'package:flutterfrontend/pages/practice_coutdown.dart';
import 'package:flutterfrontend/pages/practice_instructions.dart';
import 'package:flutterfrontend/pages/qualifying.dart';
import 'package:flutterfrontend/pages/scan_id.dart';
import 'package:flutterfrontend/state/dw_state.dart';
import 'package:flutterfrontend/state/rest_state.dart';
import 'package:flutterfrontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

void main() => runApp(const MyApp());

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
          child: ColoredBox(color: Zeta.of(context).colors.textSubtle),
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
      redirect: (context, state) => kDebugMode ? LeaderBoardsPage.name : ScanIdPage.name,
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
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataWedgeState()),
        ChangeNotifierProvider(create: (context) => RestState()),
        ChangeNotifierProxyProvider<RestState, WebSocketState>(
          create: (context) => WebSocketState(Provider.of<RestState>(context, listen: false)),
          update: (context, restState, wsState) => wsState ?? WebSocketState(restState),
        ),
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
          builder: (_, child) => Scaffold(body: child ?? const Nothing()),
        ),
      ),
    );
  }
}
