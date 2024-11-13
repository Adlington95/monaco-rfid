import 'package:flutter/material.dart';
import 'package:frontend/components/id_card.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/car_start.dart';
import 'package:frontend/state/dw_state.dart';
import 'package:provider/provider.dart';

class ScanIdPage extends StatefulWidget {
  const ScanIdPage({super.key});
  static const name = '/scan-id';

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
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => context.read<DataWedgeState>().clear(),
      child: Consumer<DataWedgeState>(
        builder: (context, state, child) {
          final provider = Provider.of<DataWedgeState>(context);

          return IdCard(
            title: provider.loggedInUser != null ? 'Welcome' : 'Scan your ID card',
            isLoading: provider.isLoading,
            onTap: provider.loggedInUser != null
                ? () => router.pushReplacement(CarStartPage.name, extra: provider.loggedInUser)
                : provider.scanBarcode,
            data: provider.loggedInUser,
          );
        },
      ),
    );
  }
}
