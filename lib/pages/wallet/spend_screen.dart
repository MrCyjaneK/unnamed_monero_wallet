import 'package:anonero/pages/wallet/spend_confirm.dart';
import 'package:anonero/tools/format_monero.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

class SpendScreen extends StatefulWidget {
  const SpendScreen({super.key, this.outputs = const [], this.address = ""});
  final String address;
  final List<String> outputs;
  @override
  State<SpendScreen> createState() => _SpendScreenState();

  static void push(BuildContext context,
      {List<String> outputs = const [], String address = ""}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return SpendScreen(outputs: outputs, address: address);
      },
    ));
  }
}

class _SpendScreenState extends State<SpendScreen> {
  late final addressCtrl = TextEditingController(text: widget.address);
  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  bool sweepAllVar = false;
  bool get sweepAll => sweepAllVar;
  final coins = MONERO_Wallet_coins(walletPtr!);

  @override
  void initState() {
    _loadBalance();
    super.initState();
  }

  void _toggleSweep() {
    setState(() {
      sweepAllVar = !sweepAllVar;
      amountCtrl.text = formatMonero(availableBalance);
    });
  }

  int availableBalance = 0;
  void _loadBalance() {
    if (widget.outputs.isEmpty) {
      setState(() {
        availableBalance =
            MONERO_Wallet_unlockedBalance(walletPtr!, accountIndex: 0);
      });
      return;
    }
    MONERO_Coins_refresh(coins);
    final count = MONERO_Coins_count(coins);
    int amt = 0;
    for (var i = 0; i < count; i++) {
      final c = MONERO_Coins_coin(coins, i);
      final keyImage = MONERO_CoinsInfo_keyImage(c);
      if (widget.outputs.contains(keyImage)) {
        amt += MONERO_CoinsInfo_amount(c);
      }
    }
    setState(() {
      availableBalance = amt;
    });
  }

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
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
        outputs: widget.outputs,
      ),
    );
  }
}
