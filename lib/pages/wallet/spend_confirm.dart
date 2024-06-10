// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/pages/ur_broadcast.dart';
import 'package:xmruw/pages/wallet/spend_screen.dart';
import 'package:xmruw/pages/wallet/spend_success.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/format_monero.dart';
import 'package:xmruw/tools/is_offline.dart';
import 'package:xmruw/tools/is_view_only.dart';
import 'package:xmruw/tools/monero/account_index.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:xmruw/widgets/padded_element.dart';
import 'package:xmruw/widgets/primary_label.dart';
import 'package:xmruw/widgets/setup_logo.dart';
import 'package:xmruw/widgets/transaction_list/popup_menu.dart';

class TxRequest {
  final String address;
  final int amount;
  final int fee;
  final String notes;
  final bool isSweep;
  final List<String> outputs;
  final Priority priority;
  final monero.UnsignedTransaction? txPtr;
  final bool isUR;
  TxRequest({
    required this.address,
    required this.amount,
    required this.notes,
    required this.priority,
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

  static Future<void> push(BuildContext context, TxRequest tx) async {
    await Navigator.of(context).push(MaterialPageRoute(
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
  monero.PendingTransaction? txPtr;
  @override
  void initState() {
    _prepTx();
    super.initState();
  }

  void _prepTx() {
    if (widget.tx.isUR) return;
    Future.delayed(const Duration(milliseconds: 700)).then((value) {
      print("outs: ${widget.tx.outputs}");
      final tx = monero.Wallet_createTransaction(
        walletPtr!,
        dst_addr: widget.tx.address,
        payment_id: "",
        amount: widget.tx.isSweep ? 0 : widget.tx.amount,
        mixin_count: 0,
        pendingTransactionPriority: widget.tx.priority.index,
        subaddr_account: globalAccountIndex,
        preferredInputs: widget.tx.outputs,
      );
      final status = monero.PendingTransaction_status(tx);
      final errorString = monero.PendingTransaction_errorString(tx);
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
    return txPtr == null ? null : monero.PendingTransaction_amount(txPtr!);
  }

  int? _getFee() {
    if (widget.tx.isUR) return widget.tx.fee;
    return txPtr == null ? null : monero.PendingTransaction_fee(txPtr!);
  }

  int? _getTotal() {
    if (widget.tx.isUR) return widget.tx.amount + widget.tx.fee;
    return txPtr == null
        ? null
        : monero.PendingTransaction_amount(txPtr!) +
            monero.PendingTransaction_fee(txPtr!);
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
          title: widget.tx.priority == Priority.default_
              ? "Fee"
              : "Fee: ${getPriorityText(widget.tx.priority)}",
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
    return monero.Wallet_hasUnknownKeyImages(walletPtr!) ||
        (monero.Wallet_viewOnlyBalance(walletPtr!,
                accountIndex: globalAccountIndex) <
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
        monero.PendingTransaction_commit(txPtr!, filename: p, overwrite: false);
    if (stat == false) {
      final errorString = monero.PendingTransaction_errorString(txPtr!);
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
      content: File(p).readAsStringSync(),
      flag: UrBroadcastPageFlag.xmrUnsignedTx,
    );
  }

  void _confirmAnon() async {
    if (isOffline) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      final content = monero.UnsignedTransaction_signUR(widget.tx.txPtr!, 120);
      UrBroadcastPage.push(
        context,
        content: content.trim(),
        flag: UrBroadcastPageFlag.xmrSignedTx,
      );
      return;
    }
    final stat = monero.PendingTransaction_commit(txPtr!,
        filename: "", overwrite: false);
    if (stat == false) {
      final errorString = monero.PendingTransaction_errorString(txPtr!);
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

    final status = monero.PendingTransaction_status(txPtr!);
    final errorString = monero.PendingTransaction_errorString(txPtr!);
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
        (amount == null)
            ? const Stack(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                  // SelectableText is here to ensure that the size of the
                  // widget is proper.
                  // SizedBox didn't work out as some people have larger fonts
                  // set in settings.
                  SelectableText(
                    "0.0",
                    style: TextStyle(color: Colors.transparent),
                  ),
                ],
              )
            : SelectableText(
                formatMonero(amount),
              ),
        const SizedBox(width: 16)
      ],
    );
  }
}
