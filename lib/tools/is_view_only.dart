import 'package:monero/monero.dart' as monero;
import 'package:xmruw/tools/wallet_ptr.dart';

bool? _isViewOnlyCache;

bool get isViewOnly {
  _isViewOnlyCache ??=
      int.tryParse(monero.Wallet_secretSpendKey(walletPtr!)) == 0;
  return _isViewOnlyCache!;
}

bool isNero = true;
bool isAnon = true;
