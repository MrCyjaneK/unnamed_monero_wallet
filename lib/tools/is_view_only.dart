import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:monero/monero.dart';

bool get isViewOnly {
  return int.tryParse(MONERO_Wallet_secretSpendKey(walletPtr!)) == 0;
}

bool isNero = true;
bool isAnon = true;
