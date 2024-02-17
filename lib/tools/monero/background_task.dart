import 'dart:async';
import 'package:monero/monero.dart';

void runBackgroundTaskWallet(MONERO_wallet wPtr) async {
  while (true) {
    await Future.delayed(const Duration(seconds: 10));
    MONERO_Wallet_store(wPtr);
  }
}
