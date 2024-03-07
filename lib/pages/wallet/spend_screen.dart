import 'package:offline_market_data/offline_market_data.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/scanner/base_scan.dart';
import 'package:xmruw/pages/wallet/spend_confirm.dart';
import 'package:xmruw/tools/format_monero.dart';
import 'package:xmruw/tools/is_offline.dart';
import 'package:xmruw/tools/monero/account_index.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_manager.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:flutter/foundation.dart';
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

enum Priority {
  default_,
  low,
  medium,
  high,
}

class _SpendScreenState extends State<SpendScreen> {
  late final addressCtrl = TextEditingController(text: widget.address);
  final amountCtrl = TextEditingController();
  final amountFiatCtrl = TextEditingController();
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
    final swp = sweepAllVar;
    setState(() {
      amountCtrl.text = formatMonero(availableBalance).split(" ")[0];
    });
    _amtEdited();
    setState(() {
      sweepAllVar = !swp;
    });
  }

  int availableBalance = 0;
  void _loadBalance() {
    if (widget.outputs.isEmpty) {
      setState(() {
        availableBalance = MONERO_Wallet_unlockedBalance(walletPtr!,
            accountIndex: globalAccountIndex);
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
    final amt = double.tryParse(amountCtrl.text);
    if (amt != null) {
      final str = formatMoneroFiat(amt * 1e12, null).split(" ")[0];
      setState(() {
        amountFiatCtrl.text = str;
      });
    }
    if (sweepAllVar) {
      setState(() {
        sweepAllVar = false;
      });
    }
  }

  void _amtFiatEdited() {
    final amt = double.tryParse(amountFiatCtrl.text);
    if (amt != null) {
      var price = CurrencyDataXMRxUSD().getPrice(null) ?? -1;

      if (config.fiatCurrency != "USD") {
        final p = usdPairs[config.fiatCurrency]?.getPrice(null);
        if (p != null) {
          price *= p;
        }
      }

      setState(() {
        amountCtrl.text = (amt / price).toStringAsFixed(12);
      });
    }
    if (sweepAllVar) {
      setState(() {
        sweepAllVar = false;
      });
    }
  }

  final viewOnlyBalance = MONERO_Wallet_viewOnlyBalance(walletPtr!,
      accountIndex: globalAccountIndex);

  final hasUnknownKeyImages = MONERO_Wallet_hasUnknownKeyImages(walletPtr!);

  bool amountInputXMR = true;

  void _switchAmountTF() {
    setState(() {
      amountInputXMR = !amountInputXMR;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Send"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                priorityIndex++;
              });
            },
            child: (priority == Priority.default_)
                ? const Text("Fee")
                : Text(
                    getPriorityText(priority),
                  ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LabeledTextInput(
              label: "ADDRESS",
              ctrl: addressCtrl,
              enabled: !isOffline,
            ),
            if (!amountInputXMR)
              LabeledTextInput(
                label: "AMOUNT",
                ctrl: amountFiatCtrl,
                onEdit: _amtFiatEdited,
                enabled: !isOffline,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(config.fiatCurrency),
                    IconButton(
                      onPressed: isOffline ? null : _switchAmountTF,
                      icon: const Icon(Icons.currency_exchange),
                    ),
                  ],
                ),
              ),
            if (amountInputXMR)
              LabeledTextInput(
                label: "AMOUNT",
                ctrl: amountCtrl,
                onEdit: _amtEdited,
                enabled: !isOffline,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("XMR"),
                    IconButton(
                      onPressed: isOffline ? null : _switchAmountTF,
                      icon: const Icon(Icons.currency_exchange),
                    ),
                  ],
                ),
              ),
            LabeledTextInput(
              label: "NOTES",
              ctrl: notesCtrl,
              enabled: !isOffline,
            ),
            InkWell(
              onTap: isOffline ? null : _toggleSweep,
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
            if (kDebugMode)
              SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    "View Only balance: ${formatMonero(viewOnlyBalance)}\n"
                    "(hasUnknownKeyImages: $hasUnknownKeyImages)",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            IconButton(
              iconSize: 48,
              onPressed: isOffline ? null : () => BaseScannerPage.push(context),
              icon: const Icon(Icons.crop_free_sharp),
            ),
          ],
        ),
      ),
      bottomNavigationBar: LongOutlinedButton(
        text: "Continue",
        onPressed: isOffline ? null : _continue,
      ),
    );
  }

  void _continue() {
    final amtNum = num.tryParse(amountCtrl.text);
    if (amtNum == null) {
      Alert(title: "Invalid amount", cancelable: true).show(context);
      return;
    }
    String address = addressCtrl.text;
    final addrUri = Uri.tryParse(address);
    if (addrUri != null && config.enableOpenAlias && address.contains(".")) {
      address = MONERO_WalletManager_resolveOpenAlias(
        wmPtr,
        address: address.replaceAll("@", "."),
        dnssecValid: false,
      );
      final errstr = MONERO_WalletManager_errorString(wmPtr);
      if (address.isEmpty) {
        Alert(title: 'Unresolvable OpenAlias\n$errstr', cancelable: true)
            .show(context);
        return;
      }
    }

    final amtInt = (amtNum * 1e12) ~/ 1;
    SpendConfirm.push(
      context,
      TxRequest(
        address: address,
        amount: amtInt,
        priority: priority,
        notes: notesCtrl.text,
        isSweep: sweepAll,
        outputs: widget.outputs,
      ),
    );
  }

  int priorityIndex = 0;
  Priority get priority =>
      Priority.values[priorityIndex % Priority.values.length];
}

String getPriorityText(Priority p) => switch (p) {
      Priority.default_ => "Default",
      Priority.low => "Low",
      Priority.medium => "Medium",
      Priority.high => "High",
    };
