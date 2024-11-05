import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterfrontend/components/id_card.dart';
import 'package:flutterfrontend/pages/car_start.dart';
import 'package:flutterfrontend/pages/leaderboards.dart';
import 'package:flutterfrontend/pages/practice.dart';
import 'package:flutterfrontend/pages/scan_id.dart';
import 'package:flutterfrontend/pages/welcome.dart';
import 'package:flutterfrontend/state/ws_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

void main() {
  runApp(const MyApp());
}

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LeaderBoardsPage(),
    ),
    GoRoute(
      path: '/scan-id',
      builder: (context, state) => const ScanIdPage(),
    ),
    GoRoute(
      path: '/practice',
      builder: (context, state) => const PracticePage(),
    ),
    GoRoute(
      path: '/car-start',
      builder: (context, state) => const CarStartPage(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => WelcomePage(data: state.extra as User),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WebSocketState(),
      child: ZetaProvider.base(
        initialThemeMode: ThemeMode.light,
        builder: (context, light, dark, themeMode) => MaterialApp.router(
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'F1',
            colorScheme: const ColorScheme.dark(),
          ),
          builder: (context, child) => ColoredBox(
            color: light.colorScheme.textSubtle,
            child: Stack(
              children: [
                Positioned(
                  left: -20,
                  top: -260,
                  child: SvgPicture.asset(
                    'lib/assets/zebrahead.svg',
                    height: 1200,
                  ),
                ),
                Scaffold(
                  body: child,
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
