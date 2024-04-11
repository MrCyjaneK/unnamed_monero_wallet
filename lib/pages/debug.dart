import 'dart:io';

import 'package:xmruw/pages/changelog.dart';
import 'package:xmruw/pages/debug/backup_test.dart';
import 'package:xmruw/pages/debug/battery_optimization.dart';
import 'package:xmruw/pages/debug/button_x_textfield.dart';
import 'package:xmruw/pages/debug/config_json.dart';
import 'package:xmruw/pages/debug/mobile_scanner.dart';
import 'package:xmruw/pages/debug/monero_dart_advanced.dart';
import 'package:xmruw/pages/debug/monero_dart_core.dart';
import 'package:xmruw/pages/debug/monero_dart_state.dart';
import 'package:xmruw/pages/debug/monero_log.dart';
import 'package:xmruw/pages/debug/monero_log_level.dart';
import 'package:xmruw/pages/debug/performance.dart';
import 'package:xmruw/pages/debug/polyseed_test.dart';
import 'package:xmruw/pages/debug/theme_config.dart';
import 'package:xmruw/pages/debug/tor_test.dart';
import 'package:xmruw/pages/debug/urqr_codes.dart';
import 'package:xmruw/pages/wallet/configuration_page.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("D38UG"),
      ),
      body: SingleChildScrollView(
        child: Column(
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
              onPressed: walletPtr == null
                  ? null
                  : () => MoneroDartState.push(context),
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
              text: "Configuration",
              onPressed: () => ConfigurationPage.push(context),
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
            if (kDebugMode)
              LongOutlinedButton(
                text: "Tor test debug",
                onPressed: (!Platform.isAndroid)
                    ? null
                    : () => TorTestDebug.push(context),
              ),
            LongOutlinedButton(
              text: "Battery Optimization",
              onPressed: (!Platform.isAndroid)
                  ? null
                  : () => BatteryOptimizationDebug.push(context),
            ),
            LongOutlinedButton(
              text: "Changelog",
              onPressed: () => ChangelogPage.push(context),
            ),
            LongOutlinedButton(
              text: "Custom theme config",
              onPressed: () => ThemeConfigPage.push(context),
            ),
            LongOutlinedButton(
              text: "Config dump",
              onPressed: () => ConfigPage.push(context),
            ),
            LongOutlinedButton(
              text: "Polyseed test",
              onPressed: () => PolyseedCompatTestDebug.push(context),
            ),
          ],
        ),
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
