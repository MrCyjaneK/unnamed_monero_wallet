import 'package:flutter/material.dart';
import 'package:libstealth_calculator/libstealth_calculator.dart';
import 'package:monero/monero.dart';
import 'package:xmruw/main_clean.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/fuck_firebase.dart';
import 'package:xmruw/tools/wallet_manager.dart';

const bool libstealthCalculator = bool.hasEnvironment("libstealth_calculator")
    ? bool.fromEnvironment("libstealth_calculator")
    : false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await fuckFirebase(); // MLkit privacy patch
  final walletExists =
      MONERO_WalletManager_walletExists(wmPtr, await getMainWalletPath());
  if (libstealthCalculator) {
    runApp(StealthHomeScreenCalculator(
      onSecretGiven: (String secret) async {
        if (!walletExists && secret.endsWith("123")) {
          main_clean();
          return;
        } else {
          if (!walletExists) return;
          final pwd = MONERO_WalletManager_verifyWalletPassword(
            wmPtr,
            keysFileName: "${await getMainWalletPath()}.keys",
            password: secret.trim(),
            noSpendKey: false,
            kdfRounds: 1,
          );
          if (!pwd) return;
          main_clean();
        }

        return;
      },
    ));
  } else {
    main_clean();
  }
}
