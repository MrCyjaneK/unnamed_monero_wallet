import 'dart:io';

import 'package:anonero/pages/debug/backup_test.dart';
import 'package:anonero/pages/debug/button_x_textfield.dart';
import 'package:anonero/pages/debug/mobile_scanner.dart';
import 'package:anonero/pages/debug/monero_dart_advanced.dart';
import 'package:anonero/pages/debug/monero_dart_core.dart';
import 'package:anonero/pages/debug/monero_dart_state.dart';
import 'package:anonero/pages/debug/monero_log.dart';
import 'package:anonero/pages/debug/monero_log_level.dart';
import 'package:anonero/pages/debug/performance.dart';
import 'package:anonero/pages/debug/boot_flag.dart';
import 'package:anonero/pages/debug/urqr_codes.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("D38UG"),
      ),
      body: Column(
        children: [
          LongOutlinedButton(
            text: "LOButton x LTextField",
            onPressed: () => ButtonTextFieldDebug.push(context),
          ),
          LongOutlinedButton(
            text: "monero.dart core",
            onPressed:
                walletPtr == null ? () => MoneroDartCore.push(context) : null,
          ),
          LongOutlinedButton(
            text: "monero.dart state",
            onPressed:
                walletPtr == null ? null : () => MoneroDartState.push(context),
          ),
          LongOutlinedButton(
            text: "monero.dart advanced",
            onPressed: walletPtr == null
                ? null
                : () => MoneroDartAdvancedDebug.push(context),
          ),
          LongOutlinedButton(
            text: "monero logs",
            onPressed: () => MoneroLogDebug.push(context),
          ),
          LongOutlinedButton(
            text: "monero loglevel",
            onPressed: walletPtr == null
                ? () => MoneroLogLevelDebug.push(context)
                : null,
          ),
          LongOutlinedButton(
            text: "Boot flags",
            onPressed: () => BootFlagDebug.push(context),
          ),
          LongOutlinedButton(
            text: "Performance",
            onPressed: () => PerformanceDebug.push(context),
          ),
          LongOutlinedButton(
            text: "Mobile_scanner",
            onPressed: (!Platform.isAndroid)
                ? null
                : () => MobileScannerDebug.push(context),
          ),
          LongOutlinedButton(
            text: "URQR",
            onPressed: (!Platform.isAndroid)
                ? null
                : () => URQRCodeDebug.push(context),
          ),
          LongOutlinedButton(
            text: "Backup",
            onPressed: (!Platform.isAndroid)
                ? null
                : () => BackupTestDebug.push(context),
          ),
        ],
      ),
    );
  }

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const DebugPage();
      },
    ));
  }
}
