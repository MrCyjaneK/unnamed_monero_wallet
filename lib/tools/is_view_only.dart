import 'package:anonero/tools/wallet_ptr.dart';
import 'package:monero/monero.dart';

bool get isViewOnly {
  return int.tryParse(MONERO_Wallet_secretSpendKey(walletPtr!)) == 0;
}
