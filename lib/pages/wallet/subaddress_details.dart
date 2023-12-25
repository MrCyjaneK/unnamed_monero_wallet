import 'package:anonero/legacy.dart';
import 'package:anonero/pages/wallet/subaddress_page.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/qr_code.dart';
import 'package:anonero/widgets/transaction_list/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SubaddressDetailsPage extends StatelessWidget {
  SubaddressDetailsPage({super.key, required this.subaddressId});

  final int subaddressId;

  void _copyAddress() {
    Clipboard.setData(const ClipboardData(text: 'text'));
  }

  void _showQr(BuildContext c) {
    Alert(
      cancelable: false,
      body: [
        const SizedBox(
          width: 512,
          child: Qr(
            data: 'text',
          ),
        )
      ],
    ).show(c);
  }

  final renameCtrl = TextEditingController(text: "current name");

  void _rename(BuildContext c) {
    Alert(
      body: [
        SizedBox(
            width: double.maxFinite,
            child:
                LabeledTextInput(label: "Rename subaddress", ctrl: renameCtrl)),
      ],
      cancelable: true,
      callback: () {},
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
                label: "label",
                received: 1234567890123,
                squashedAddress:
                    'squashedAddresssquashedAddresssquashedAddresssquashedAddresssquashedAddresssquashedAddress',
              ),
              const SizedBox(
                height: 16,
              ),
              TransactionItem(
                  transaction: Transaction(
                confirmations: 3,
              )),
              TransactionItem(
                transaction: Transaction(confirmations: 9)
                  ..amount = 1234567890120
                  ..isSpend = true,
              ),
              TransactionItem(
                  transaction: Transaction(confirmations: 25)..isSpend = true),
              TransactionItem(
                  transaction: Transaction(confirmations: 90)
                    ..amount = 1234567890120),
              TransactionItem(transaction: Transaction(confirmations: 532)),
              TransactionItem(
                  transaction: Transaction(confirmations: 53151)
                    ..isSpend = true),
              TransactionItem(transaction: Transaction(confirmations: 533135)),
              TransactionItem(transaction: Transaction(confirmations: 5111353)),
              TransactionItem(transaction: Transaction(confirmations: 532)),
              TransactionItem(transaction: Transaction(confirmations: 532)),
              TransactionItem(transaction: Transaction(confirmations: 532)),
              TransactionItem(transaction: Transaction(confirmations: 532)),
              TransactionItem(transaction: Transaction(confirmations: 532)),
              TransactionItem(transaction: Transaction(confirmations: 532)),
              TransactionItem(transaction: Transaction(confirmations: 532)),
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
