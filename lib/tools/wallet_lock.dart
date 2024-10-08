import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';

DateTime lastClick = DateTime.now();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const lockAfter = 5 * 60;
void lockIfShould() {
  if (!config.enableAutoLock) {
    lastClick = DateTime.now();
    return;
  }
  if (DateTime.now().difference(lastClick).inSeconds <= lockAfter) {
    return;
  }
  if (isLocked) return;
  final context = navigatorKey.currentContext!;
  if (tempWalletPassword != "") {
    final stat = monero.Wallet_setupBackgroundSync(
      walletPtr!,
      backgroundSyncType: 1,
      walletPassword: tempWalletPassword,
      backgroundCachePassword: "",
    );
    if (!stat) {
      Alert(title: monero.Wallet_errorString(walletPtr!), cancelable: true)
          .show(context);
      return;
    }
    tempWalletPassword = "";
  }
  final status = monero.Wallet_startBackgroundSync(walletPtr!);
  if (!status) {
    Alert(
      title: monero.Wallet_errorString(walletPtr!),
      cancelable: true,
    ).show(context);
    return;
  }
  PinScreen.pushLock(context);
}

void initLock() {
  Timer.periodic(const Duration(seconds: 1), (timer) {
    lockIfShould();
  });
}
