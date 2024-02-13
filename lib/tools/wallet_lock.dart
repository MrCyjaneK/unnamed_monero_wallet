import 'dart:async';

import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

DateTime lastClick = DateTime.now();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void lockIfShould() {
  if (DateTime.now().difference(lastClick).inSeconds <= 5 * 60) {
    return;
  }
  if (isLocked) return;
  final context = navigatorKey.currentContext!;
  if (tempWalletPassword != "") {
    final stat = MONERO_Wallet_setupBackgroundSync(
      walletPtr!,
      backgroundSyncType: 1,
      walletPassword: tempWalletPassword,
      backgroundCachePassword: "",
    );
    if (!stat) {
      Alert(title: MONERO_Wallet_errorString(walletPtr!), cancelable: true)
          .show(context);
      return;
    }
    tempWalletPassword = "";
  }
  final status = MONERO_Wallet_startBackgroundSync(walletPtr!);
  if (!status) {
    Alert(
      title: MONERO_Wallet_errorString(walletPtr!),
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
