import 'package:monero/monero.dart' as monero;
import 'package:xmruw/tools/monero/account_index.dart';
import 'package:xmruw/tools/wallet_ptr.dart';

String subaddressLabel(int addressIndex) {
  final label = monero.Wallet_getSubaddressLabel(walletPtr!,
      accountIndex: globalAccountIndex, addressIndex: addressIndex);
  if (label == "") return "SUBADDRESS #$addressIndex";
  return label;
}
