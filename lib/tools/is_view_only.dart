import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:monero/monero.dart';

bool? _isViewOnlyCache;

bool get isViewOnly {
  _isViewOnlyCache ??=
      int.tryParse(MONERO_Wallet_secretSpendKey(walletPtr!)) == 0;
  return _isViewOnlyCache!;
}

bool isNero = true;
bool isAnon = true;
