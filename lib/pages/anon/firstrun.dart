import 'package:xmruw/pages/setup/backup_restore.dart';
import 'package:xmruw/pages/setup/node_connection.dart';
import 'package:xmruw/tools/backup_class.dart';
import 'package:xmruw/tools/can_backup.dart';
import 'package:xmruw/tools/is_view_only.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/widgets/debug_icon_first_run.dart';
import 'package:xmruw/widgets/setup_logo.dart';
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
          const Center(child: DebugIconFirstRun()),
          const Spacer(),
          if (isAnon)
            SetupOutlinedButton(
              text: "CREATE WALLET",
              onPressed: () => SetupNodeConnection.push(
                context,
                SetupNodeConnectionFlag.createWallet,
              ),
            ),
          const SizedBox(height: 24),
          if (isAnon)
            SetupOutlinedButton(
              text: "RESTORE WALLET",
              onPressed: () => _restoreWallet(context),
            ),
          if (isNero)
            SetupOutlinedButton(
              text: "ViewOnly",
              onPressed: () => _restoreWalletNero(context),
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
        LongAlertButtonAlt(
          text: "RESTORE FROM BACKUP",
          callback: !canBackup() ? null : () => _restoreFromBackup(c),
        ),
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
    Navigator.of(c).pop();
    SetupNodeConnection.push(c, SetupNodeConnectionFlag.restoreWalletSeed);
  }

  void _restoreFromBackup(BuildContext c) async {
    Navigator.of(c).pop();
    final bd = await BackupDetails.decrypt(c);
    // ignore: use_build_context_synchronously
    BackupRestorePage.push(c, bd);
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
