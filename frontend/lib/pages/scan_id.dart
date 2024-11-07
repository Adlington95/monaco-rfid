import 'package:flutter/material.dart';
import 'package:flutterfrontend/components/id_card.dart';
import 'package:flutterfrontend/main.dart';
import 'package:flutterfrontend/pages/car_start.dart';
import 'package:flutterfrontend/state/dw_state.dart';
import 'package:provider/provider.dart';

class ScanIdPage extends StatefulWidget {
  static const name = '/scan-id';
  const ScanIdPage({super.key});

  @override
  State<ScanIdPage> createState() => _ScanIdPageState();
}

class _ScanIdPageState extends State<ScanIdPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataWedgeState>().initScanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataWedgeState>(builder: (context, state, child) {
      final provider = Provider.of<DataWedgeState>(context);

      return IdCard(
        title: provider.loggedInUser != null ? 'Welcome' : 'Scan your ID card',
        onTap: provider.loggedInUser != null
            ? () => router.go(CarStartPage.name, extra: provider.loggedInUser)
            : provider.scanBarcode,
        data: provider.loggedInUser,
      );
    });
  }
}
