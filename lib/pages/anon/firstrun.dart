import 'package:anonero/const/app_name.dart';
import 'package:anonero/const/resource.g.dart';
import 'package:anonero/pages/debug.dart';
import 'package:anonero/pages/setup/node_connection.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// _restoreWallet -> BuildContext
class AnonFirstRun extends StatelessWidget {
  const AnonFirstRun({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Center(child: Image.asset(R.ASSETS_ANON_LOGO_PNG)),
          const Spacer(),
          SetupOutlinedButton(
            text: "CREATE WALLET",
            onPressed: () => SetupNodeConnection.push(
              context,
              SetupNodeConnectionFlag.createWallet,
            ),
          ),
          const SizedBox(height: 24),
          SetupOutlinedButton(
            text: "RESTORE WALLET $anon",
            onPressed: () => _restoreWallet(context),
          ),
          SetupOutlinedButton(
            text: "RESTORE WALLET $nero",
            onPressed: () => _restoreWalletNero(context),
          ),
          if (kDebugMode)
            SetupOutlinedButton(
              text: "D3B8G",
              onPressed: () => DebugPage.push(context),
            ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  void _restoreWalletNero(BuildContext c) {
    SetupNodeConnection.push(c, SetupNodeConnectionFlag.restoreWalletNero);
  }

  void _restoreWallet(BuildContext c) {
    Alert(
      singleBody: const SetupLogo(
        title: "Restore",
        width: 80,
        fontSize: 18,
      ),
      overrideActions: [
        const LongAlertButtonAlt(text: "RESTORE FROM BACKUP"),
        const Divider(),
        LongAlertButtonAlt(
          text: "RESTORE FROM SEED",
          callback: () => _restoreFromSeed(c),
        ),
        const SizedBox(height: 16)
      ],
    ).show(c);
  }

  void _restoreFromSeed(BuildContext c) {
    SetupNodeConnection.push(c, SetupNodeConnectionFlag.restoreWalletSeed);
  }
}

class SetupOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const SetupOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1.0, color: Colors.white),
              shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 12, color: Colors.white),
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
            ),
            onPressed: onPressed,
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
