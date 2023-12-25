import 'package:anonero/pages/wallet/spend_confirm.dart';
import 'package:anonero/tools/format_monero.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class SpendScreen extends StatefulWidget {
  const SpendScreen({super.key});

  @override
  State<SpendScreen> createState() => _SpendScreenState();
}

const tempAvailableBalance = "9123456789012";

class _SpendScreenState extends State<SpendScreen> {
  final addressCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  bool sweepAllVar = false;
  bool get sweepAll => sweepAllVar;

  void _toggleSweep() {
    setState(() {
      sweepAllVar = !sweepAllVar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          LabeledTextInput(label: "ADDRESS", ctrl: addressCtrl),
          LabeledTextInput(label: "AMOUNT", ctrl: amountCtrl),
          LabeledTextInput(label: "NOTES", ctrl: notesCtrl),
          InkWell(
            onTap: _toggleSweep,
            child: SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  sweepAll
                      ? "Sweeping ${formatMonero(num.tryParse(tempAvailableBalance))} (minus fee)"
                      : "Available Balance : ${formatMonero(num.tryParse(tempAvailableBalance))}",
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
      Alert(title: "Invalid amount").show(context);
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
