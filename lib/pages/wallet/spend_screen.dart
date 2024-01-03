import 'package:anonero/pages/wallet/spend_confirm.dart';
import 'package:anonero/tools/format_monero.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

class SpendScreen extends StatefulWidget {
  const SpendScreen({super.key});

  @override
  State<SpendScreen> createState() => _SpendScreenState();
}

class _SpendScreenState extends State<SpendScreen> {
  final addressCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  bool sweepAllVar = false;
  bool get sweepAll => sweepAllVar;

  void _toggleSweep() {
    setState(() {
      sweepAllVar = !sweepAllVar;
      amountCtrl.text = formatMonero(availableBalance);
    });
  }

  final availableBalance =
      MONERO_Wallet_unlockedBalance(walletPtr!, accountIndex: 0);

  void _amtEdited() {
    if (sweepAllVar) {
      setState(() {
        sweepAllVar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          LabeledTextInput(label: "ADDRESS", ctrl: addressCtrl),
          LabeledTextInput(
            label: "AMOUNT",
            ctrl: amountCtrl,
            onEdit: _amtEdited,
          ),
          LabeledTextInput(label: "NOTES", ctrl: notesCtrl),
          InkWell(
            onTap: _toggleSweep,
            child: SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  sweepAll
                      ? "Sweeping ${formatMonero(availableBalance)} (minus fee)"
                      : "Available Balance : ${formatMonero(availableBalance)}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
          IconButton(
            iconSize: 48,
            onPressed: () {},
            icon: const Icon(Icons.crop_free_sharp),
          ),
          const Spacer(),
          LongOutlinedButton(
            text: "Continue",
            onPressed: _continue,
          ),
        ],
      ),
    );
  }

  void _continue() {
    final amtNum = num.tryParse(amountCtrl.text);
    if (amtNum == null) {
      Alert(title: "Invalid amount", cancelable: true).show(context);
      return;
    }
    final amtInt = (amtNum * 1e12) ~/ 1;
    SpendConfirm.push(
      context,
      TxRequest(
        address: addressCtrl.text,
        amount: amtInt,
        notes: notesCtrl.text,
        isSweep: sweepAll,
      ),
    );
  }
}
