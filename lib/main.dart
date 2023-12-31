import 'dart:convert';
import 'dart:io';

import 'package:anonero/legacy.dart';
import 'package:anonero/pages/anon/firstrun.dart';
import 'package:anonero/pages/pin_screen.dart';
import 'package:anonero/tools/dirs.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

bool _walletExists = false;
bool useMaterial3 = false;
bool showPerformanceOverlay = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pmf = File(await getPerformanceStoreFile());
  if (pmf.existsSync()) {
    debugCallLength = json.decode(pmf.readAsStringSync());
  }
  _walletExists = MONERO_WalletManager_walletExists(await getMainWalletPath());
  useMaterial3 = File(await getMaterial3FlagFile()).existsSync();
  showPerformanceOverlay =
      File(await getShowPerformanceOverlayFlagFile()).existsSync();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: showPerformanceOverlay,
      title: 'Anonero',
      theme: ThemeData(
        fontFamily: 'RobotoMono',
        colorScheme: colorScheme,
        dividerTheme: const DividerThemeData(
          thickness: 3,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.background, // ?material2 compat
        ),
        dialogBackgroundColor: colorScheme.background, // ?material2 compat
        scaffoldBackgroundColor: colorScheme.background, // material2 compat
        useMaterial3: useMaterial3,
      ),
      home: _walletExists
          ? const PinScreen(
              flag: PinScreenFlag.openMainWallet,
            )
          : const AnonFirstRun(),
    );
  }
}
