import 'package:anonero/pages/wallet/spend_success.dart';
import 'package:anonero/tools/format_monero.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/padded_element.dart';
import 'package:anonero/widgets/primary_label.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

class TxRequest {
  final String address;
  final int amount;
  final String notes;
  final bool isSweep;
  final List<String> outputs;
  TxRequest({
    required this.address,
    required this.amount,
    required this.notes,
    required this.isSweep,
    required this.outputs,
  });
}

class SpendConfirm extends StatefulWidget {
  const SpendConfirm({super.key, required this.tx});

  final TxRequest tx;

  @override
  State<SpendConfirm> createState() => _SpendConfirmState();

  static void push(BuildContext context, TxRequest tx) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return SpendConfirm(tx: tx);
      },
    ));
  }
}

class _SpendConfirmState extends State<SpendConfirm> {
  MONERO_PendingTransaction? txPtr;
  @override
  void initState() {
    _placeholderTriggerDone();
    super.initState();
  }

  void _placeholderTriggerDone() {
    Future.delayed(const Duration(milliseconds: 700)).then((value) {
      print("outs: ${widget.tx.outputs}");
      final tx = MONERO_Wallet_createTransaction(
        walletPtr!,
        dst_addr: widget.tx.address,
        payment_id: "",
        amount: widget.tx.isSweep ? 0 : widget.tx.amount,
        mixin_count: 0,
        pendingTransactionPriority: 0,
        subaddr_account: 0,
        preferredInputs: widget.tx.outputs,
      );
      final status = MONERO_PendingTransaction_status(tx);
      final errorString = MONERO_PendingTransaction_errorString(tx);
      if (status != 0) {
        Alert(
          title: errorString,
          callback: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          callbackText: "Go Back",
        ).show(context);

        return;
      }
      setState(() {
        txPtr = tx;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        const SetupLogo(title: null),
        const PrimaryLabel(title: "Address"),
        PaddedElement(child: SelectableText(widget.tx.address)),
        const PrimaryLabel(title: "Description"),
        PaddedElement(
          child:
              SelectableText(widget.tx.notes == "" ? "N/A" : widget.tx.notes),
        ),
        StatusRow(
          title: "Amount",
          amount:
              txPtr == null ? null : MONERO_PendingTransaction_amount(txPtr!),
        ),
        StatusRow(
          title: "Fee",
          amount: txPtr == null ? null : MONERO_PendingTransaction_fee(txPtr!),
        ),
        StatusRow(
          title: "Total",
          amount: txPtr == null
              ? null
              : MONERO_PendingTransaction_amount(txPtr!) +
                  MONERO_PendingTransaction_fee(txPtr!),
        ),
        const Spacer(),
        LongOutlinedButton(
          text: "CONFIRM",
          onPressed: txPtr == null ? null : _confirm,
        ),
      ]),
    );
  }

  void _confirm() {
    final stat = MONERO_PendingTransaction_commit(txPtr!,
        filename: "", overwrite: false);
    if (stat == false) {
      final errorString = MONERO_PendingTransaction_errorString(txPtr!);
      Alert(
        title: "Failed to send transaction - $errorString",
        callback: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        callbackText: "Go Back",
      ).show(context);
      return;
    }

    final status = MONERO_PendingTransaction_status(txPtr!);
    final errorString = MONERO_PendingTransaction_errorString(txPtr!);
    if (status != 0) {
      Alert(
        title: errorString,
        callback: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        callbackText: "Go Back",
      ).show(context);
      return;
    }
    SpendSuccess.push(context);
  }
}

class StatusRow extends StatelessWidget {
  const StatusRow({
    super.key,
    required this.title,
    required this.amount,
  });
  final String title;
  final int? amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: PrimaryLabel(title: title)),
        SizedBox(
          height: 16,
          child: (amount == null)
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 1),
                )
              : SelectableText(
                  formatMonero(amount),
                ),
        ),
        const SizedBox(width: 16)
      ],
    );
  }
}
