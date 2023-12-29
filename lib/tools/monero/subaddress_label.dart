import 'package:anonero/tools/wallet_ptr.dart';
import 'package:monero/monero.dart';

String subaddressLabel(int addressIndex) {
  final label = MONERO_Wallet_getSubaddressLabel(walletPtr!,
      accountIndex: 0, addressIndex: addressIndex);
  if (label == "") return "SUBADDRESS #$addressIndex";
  return label;
}
