// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:xmruw/pages/ur_broadcast.dart';
import 'package:xmruw/pages/wallet/spend_success.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/format_monero.dart';
import 'package:xmruw/tools/is_offline.dart';
import 'package:xmruw/tools/is_view_only.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:xmruw/widgets/padded_element.dart';
import 'package:xmruw/widgets/primary_label.dart';
import 'package:xmruw/widgets/setup_logo.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';
import 'package:xmruw/widgets/transaction_list/popup_menu.dart';

class TxRequest {
  final String address;
  final int amount;
  final int fee;
  final String notes;
  final bool isSweep;
  final List<String> outputs;
  final MONERO_UnsignedTransaction? txPtr;
  final bool isUR;
  TxRequest({
    required this.address,
    required this.amount,
    required this.notes,
    this.fee = 0,
    required this.isSweep,
    required this.outputs,
    this.isUR = false,
    this.txPtr,
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

  static void pushReplace(BuildContext context, TxRequest tx) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
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
    _prepTx();
    super.initState();
  }

  void _prepTx() {
    if (widget.tx.isUR) return;
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

  int? _getAmount() {
    if (widget.tx.isUR) return widget.tx.amount;
    return txPtr == null ? null : MONERO_PendingTransaction_amount(txPtr!);
  }

  int? _getFee() {
    if (widget.tx.isUR) return widget.tx.fee;
    return txPtr == null ? null : MONERO_PendingTransaction_fee(txPtr!);
  }

  int? _getTotal() {
    if (widget.tx.isUR) return widget.tx.amount + widget.tx.fee;
    return txPtr == null
        ? null
        : MONERO_PendingTransaction_amount(txPtr!) +
            MONERO_PendingTransaction_fee(txPtr!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        const SetupLogo(title: null),
        const PrimaryLabel(title: "Address"),
        PaddedElement(
            child: SelectableText(
                widget.tx.address.replaceAll(";", "\n\n").trim())),
        const PrimaryLabel(title: "Description"),
        PaddedElement(
          child:
              SelectableText(widget.tx.notes == "" ? "N/A" : widget.tx.notes),
        ),
        StatusRow(
          title: "Amount",
          amount: _getAmount(),
        ),
        StatusRow(
          title: "Fee",
          amount: _getFee(),
        ),
        StatusRow(
          title: "Total",
          amount: _getTotal(),
        ),
        const Spacer(),
        LongOutlinedButton(
          text: _needExportOutputs() ? "EXPORT OUTPUTS" : "CONFIRM",
          onPressed: (txPtr == null && !widget.tx.isUR) ? null : _confirm,
        ),
      ]),
    );
  }

  bool _needExportOutputs() {
    if (isOffline) return false;
    return MONERO_Wallet_hasUnknownKeyImages(walletPtr!) |
        (MONERO_Wallet_viewOnlyBalance(walletPtr!, accountIndex: 0) <
            (_getAmount() ?? 0x7FFFFFFFFFFFFFFF));
  }

  void _confirm() {
    isViewOnly ? _confirmNero() : _confirmAnon();
  }

  void _confirmNero() async {
    if (_needExportOutputs()) {
      await exportOutputs(context);
      setState(() {});
      return;
    }

    final p = await getMoneroUnsignedTxPath();
    if (File(p).existsSync()) File(p).deleteSync();
    final stat =
        MONERO_PendingTransaction_commit(txPtr!, filename: p, overwrite: false);
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
    UrBroadcastPage.push(
      context,
      filePath: p,
      flag: UrBroadcastPageFlag.xmrUnsignedTx,
    );
  }

  void _confirmAnon() async {
    if (isOffline) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      final signedFileName = await getMoneroSignedTxPath();
      MONERO_UnsignedTransaction_sign(widget.tx.txPtr!, signedFileName);
      UrBroadcastPage.push(
        context,
        filePath: signedFileName,
        flag: UrBroadcastPageFlag.xmrSignedTx,
      );
      return;
    }
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
