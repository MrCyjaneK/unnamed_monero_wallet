import 'dart:io';

import 'package:anonero/tools/dirs.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:monero/monero.dart';

bool get isViewOnly {
  return int.tryParse(MONERO_Wallet_secretSpendKey(walletPtr!)) == 0;
}

bool isNero = true;
bool isAnon = true;

Future<bool> isNeroFn() async {
  if (Platform.isLinux) return true;
  return (await getWd()).path.contains("io.anonero.nero");
}

Future<bool> isAnonFn() async {
  if (Platform.isLinux) return true;
  return (await getWd()).path.contains("io.anonero.anon");
}
