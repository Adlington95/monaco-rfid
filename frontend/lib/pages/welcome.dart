import 'package:flutter/material.dart';
import 'package:flutterfrontend/components/id_card.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.data});
  final User data;
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    timer();
  }

  void timer() => Future.delayed(const Duration(seconds: 5), () => redirect());

  void redirect() {
    if (mounted) context.go('/car-start');
  }

  @override
  Widget build(BuildContext context) {
    return IdCard(
      title: 'Welcome',
      data: widget.data,
      onTap: redirect,
    );
  }
}
