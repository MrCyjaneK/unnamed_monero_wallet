import 'package:flutter/material.dart';
import 'package:libstealth_calculator/libstealth_calculator.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/main_clean.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/fuck_firebase.dart';
import 'package:xmruw/tools/wallet_manager.dart';

const bool libstealthCalculator = bool.hasEnvironment("libstealth_calculator")
    ? bool.fromEnvironment("libstealth_calculator")
    : false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadConfig();

  await fuckFirebase(); // MLkit privacy patch
  final walletExists =
      monero.WalletManager_walletExists(wmPtr, await getMainWalletPath());
  if (libstealthCalculator) {
    monero.WalletManager_walletExists(wmPtr, await getMainWalletPath());
    runApp(StealthHomeScreenCalculator(
      onSecretGiven: (String secret) async {
        if (!walletExists && secret.endsWith("123")) {
          mainClean();
          return;
        } else {
          if (!walletExists) return;
          final pwd = monero.WalletManager_verifyWalletPassword(
            wmPtr,
            keysFileName: "${await getMainWalletPath()}.keys",
            password: secret.trim(),
            noSpendKey: false,
            kdfRounds: 1,
          );
          if (!pwd) return;
          mainClean();
        }
        return;
      },
    ));
  } else {
    mainClean();
  }
}
