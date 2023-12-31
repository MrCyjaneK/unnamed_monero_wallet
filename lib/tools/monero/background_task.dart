import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:anonero/tools/dirs.dart';
import 'package:monero/monero.dart';

void runBackgroundTaskWallet(MONERO_wallet wPtr) async {
  final pmf = File(await getPerformanceStoreFile());
  Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
    MONERO_Wallet_store(wPtr);
    pmf.writeAsString(json.encode(debugCallLength));
  });
}
