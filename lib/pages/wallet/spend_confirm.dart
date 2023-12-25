import 'package:anonero/pages/progress_screen.dart';
import 'package:anonero/tools/format_monero.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/padded_element.dart';
import 'package:anonero/widgets/primary_label.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/material.dart';

class TxRequest {
  final String address;
  final int amount;
  final String notes;
  final bool isSweep;

  TxRequest({
    required this.address,
    required this.amount,
    required this.notes,
    required this.isSweep,
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
  bool isDone = false;

  @override
  void initState() {
    _placeholderTriggerDone();
    super.initState();
  }

  void _placeholderTriggerDone() {
    Future.delayed(const Duration(milliseconds: 999)).then((value) {
      setState(() {
        isDone = true;
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
              !isDone ? null : widget.tx.amount - (widget.tx.amount / 10) ~/ 1,
        ),
        StatusRow(
          title: "Fee",
          amount: !isDone ? null : widget.tx.amount / 10 ~/ 1,
        ),
        StatusRow(
          title: "Total",
          amount: !isDone ? null : widget.tx.amount ~/ 1,
        ),
        const Spacer(),
        LongOutlinedButton(
          text: "CONFIRM",
          onPressed: !isDone ? null : _confirm,
        ),
      ]),
    );
  }

  void _confirm() {
    ProgressScreen.push(context, ProgressScreenFlag.txPending);
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
