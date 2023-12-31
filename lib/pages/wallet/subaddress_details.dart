import 'package:anonero/pages/wallet/subaddress_page.dart';
import 'package:anonero/tools/monero/subaddress_label.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monero/monero.dart';

class SubaddressDetailsPage extends StatelessWidget {
  SubaddressDetailsPage({super.key, required this.subaddressId});

  final int subaddressId;

  void _copyAddress() {
    Clipboard.setData(ClipboardData(
        text: MONERO_Wallet_address(walletPtr!, addressIndex: subaddressId)));
  }

  void _showQr(BuildContext c) {
    Alert(
        cancelable: false,
        singleBody: SizedBox(
          width: 512,
          child: Qr(
            data: MONERO_Wallet_address(walletPtr!, addressIndex: subaddressId),
          ),
        )).show(c);
  }

  late final renameCtrl =
      TextEditingController(text: subaddressLabel(subaddressId));

  void _rename(BuildContext c) {
    Alert(
      singleBody: SizedBox(
        width: double.maxFinite,
        child: LabeledTextInput(
          label: "Rename subaddress",
          ctrl: renameCtrl,
        ),
      ),
      cancelable: true,
      callback: () {
        MONERO_Wallet_setSubaddressLabel(
          walletPtr!,
          accountIndex: 0,
          addressIndex: subaddressId,
          label: renameCtrl.text,
        );
        Navigator.of(c).pop();
      },
    ).show(c);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _copyAddress, icon: const Icon(Icons.copy)),
          IconButton(
            onPressed: () => _rename(context),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _showQr(context),
            icon: const Icon(Icons.qr_code_2_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              SubaddressItem(
                shouldSquash: false,
                subaddressId: subaddressId,
                label: subaddressLabel(subaddressId),
                received: MONERO_Wallet_unlockedBalance(walletPtr!,
                    accountIndex: subaddressId),
                squashedAddress: MONERO_Wallet_address(walletPtr!,
                    addressIndex: subaddressId),
              ),
              const SizedBox(
                height: 16,
              ),
              // TransactionItem(transaction: Transaction(confirmations: 532)),
            ],
          ),
        ),
      ),
    );
  }

  static void push(BuildContext context, {required int subaddressId}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return SubaddressDetailsPage(
          subaddressId: subaddressId,
        );
      },
    ));
  }
}
