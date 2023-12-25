import 'package:anonero/pages/setup/polyseed_mnemonic.dart';
import 'package:anonero/pages/wallet/spend_success.dart';
import 'package:anonero/pages/wallet/wallet_home.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/material.dart';

enum ProgressScreenFlag { walletCreation, walletRestore, txPending }

// _finishProcessing uses context
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.flag});

  final ProgressScreenFlag flag;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        body: InkWell(
          onTap: () => _finishProcessing(context),
          child: const Stack(
            children: [
              Center(
                child: SizedBox.square(
                  dimension: 325,
                  child: CircularProgressIndicator(),
                ),
              ),
              Center(child: SetupLogo(title: "Loading")),
            ],
          ),
        ),
      ),
    );
  }

  void _finishProcessing(BuildContext c) {
    switch (flag) {
      case ProgressScreenFlag.walletCreation:
        PolyseedMnemonic.push(c);
      case ProgressScreenFlag.walletRestore:
        WalletHome.push(c);
      case ProgressScreenFlag.txPending:
        SpendSuccess.push(c);
    }
  }

  static void push(BuildContext context, ProgressScreenFlag flag) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return ProgressScreen(flag: flag);
      },
    ));
  }
}
