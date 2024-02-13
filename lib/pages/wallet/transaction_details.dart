import 'package:xmruw/legacy.dart';
import 'package:xmruw/pages/wallet/transaction_list.dart';
import 'package:xmruw/tools/format_monero.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/primary_label.dart';
import 'package:xmruw/widgets/transaction_list/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

class TransactionDetails extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetails({super.key, required this.transaction});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();

  static Future<void> push(
      BuildContext context, Transaction transaction) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return TransactionDetails(transaction: transaction);
      },
    ));
  }
}

class _TransactionDetailsState extends State<TransactionDetails> {
  late String description = widget.transaction.description;

  void _editCaption() async {
    final tCtrl = TextEditingController();
    await Alert(
      body: [
        LabeledTextInput(label: "New description", ctrl: tCtrl),
      ],
      callback: () => Navigator.of(context).pop(),
    ).show(context);

    MONERO_TransactionHistory_setTxNote(
      txHistoryPtr,
      txid: widget.transaction.hash,
      note: tCtrl.text,
    );
    print(MONERO_Wallet_status(walletPtr!));
    print(MONERO_Wallet_errorString(walletPtr!));
    setState(() {
      description = tCtrl.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            TransactionItem(transaction: widget.transaction, clickable: false),
            const SizedBox(height: 8),
            ListTile(
              title: const PrimaryLabel(
                title: "DESTINATION",
                enablePadding: false,
              ),
              subtitle: SelectableText(
                widget.transaction.address,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const PrimaryLabel(
                title: "DESCRIPTION",
                enablePadding: false,
              ),
              subtitle: SelectableText(
                description,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editCaption,
              ),
            ),
            const SizedBox(height: 24),
            _simpleDetail("TRANSACTION ID", widget.transaction.hash),
            const SizedBox(height: 24),
            _simpleDetail(
                "TRANSACTION FEE", formatMonero(widget.transaction.fee)),
            const SizedBox(height: 24),
            _simpleDetail("CONFIRMATION BLOCK",
                widget.transaction.blockheight.toString()),
            const SizedBox(height: 24),
            _simpleDetail(
                "TIMESTAMP", widget.transaction.timeStamp.toIso8601String()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  ListTile _simpleDetail(String title, String subtitle) {
    return ListTile(
      title: PrimaryLabel(
        title: title,
        enablePadding: false,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SelectableText(
          subtitle,
        ),
      ),
    );
  }
}
