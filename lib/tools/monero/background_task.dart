import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:anonero/tools/dirs.dart';
import 'package:monero/monero.dart';

void runBackgroundTaskWallet(MONERO_wallet wPtr) async {
  final pmf = File(await getPerformanceStoreFile());
  while (true) {
    await Future.delayed(const Duration(seconds: 10));
    MONERO_Wallet_store(wPtr);
    pmf.writeAsStringSync(json.encode(debugCallLength));
  }
}
