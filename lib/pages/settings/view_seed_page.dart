import 'dart:convert';

import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:xmruw/widgets/padded_element.dart';
import 'package:xmruw/widgets/primary_label.dart';
import 'package:xmruw/widgets/qr_code.dart';
import 'package:xmruw/widgets/tiny_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monero/monero.dart';

class ViewSeedPage extends StatefulWidget {
  const ViewSeedPage({super.key, required this.seedOffset});

  final String seedOffset;

  @override
  State<ViewSeedPage> createState() => _ViewSeedPageState();

  static void push(BuildContext context, {required String seedOffset}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return ViewSeedPage(
          seedOffset: seedOffset,
        );
      },
    ));
  }
}

class _ViewSeedPageState extends State<ViewSeedPage> {
  final address = MONERO_Wallet_address(walletPtr!);

  late final legacySeed =
      MONERO_Wallet_seed(walletPtr!, seedOffset: widget.seedOffset).split(' ');

  late final seed =
      MONERO_Wallet_getPolyseed(walletPtr!, passphrase: widget.seedOffset)
          .split(' ');

  late bool useLegacy = seed.isEmpty;

  void _toggleSeed() {
    setState(() {
      useLegacy = !useLegacy;
    });
  }

  String getData() {
    return const JsonEncoder.withIndent('   ').convert({
      "version": 0,
      "primaryAddress":
          MONERO_Wallet_address(walletPtr!, accountIndex: 0, addressIndex: 0),
      "privateViewKey": MONERO_Wallet_secretViewKey(walletPtr!),
      "restoreHeight": MONERO_Wallet_getRefreshFromBlockHeight(walletPtr!),
    });
  }

  void _showQubesKeys() {
    final data = getData();
    Alert(
      cancelable: true,
      singleBody: SelectableText(data),
    ).show(context);
  }

  void _showNeroKeys() {
    final data = getData();
    Alert(
      cancelable: false,
      singleBody: SizedBox(
        width: 512,
        child: Qr(
          data: data,
        ),
      ),
    ).show(context);
  }

  String viewKey = MONERO_Wallet_secretViewKey(walletPtr!);
  String spendKey = MONERO_Wallet_secretSpendKey(walletPtr!);
  int restoreHeight = MONERO_Wallet_getRefreshFromBlockHeight(walletPtr!);

  void _copySeed() {
    Clipboard.setData(
      ClipboardData(
        text: (useLegacy ? legacySeed : seed).join(' '),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seed"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PrimaryLabel(title: "PRIMARY ADDRESS"),
              PaddedElement(child: SelectableText(address)),
              const Divider(),
              PrimaryLabel(
                  title: useLegacy ? "LEGACY MNEMONIC" : "POLYSEED MNEMONIC"),
              InkWell(
                onTap: !seed.isNotEmpty ? null : _toggleSeed,
                onLongPress: _copySeed,
                child: PaddedElement(child: _seedWidget()),
              ),
              const Divider(),
              const PrimaryLabel(title: "VIEW-KEY"),
              PaddedElement(child: SelectableText(viewKey)),
              const Divider(),
              const PrimaryLabel(title: "SPEND-KEY"),
              PaddedElement(child: SelectableText(spendKey)),
              const Divider(),
              const PrimaryLabel(title: "RESTORE HEIGHT"),
              InkWell(
                  onTap: _changeHeight,
                  child: PaddedElement(
                      child: SelectableText(restoreHeight.toString()))),
              const Divider(),
              LongOutlinedButton(
                text: "EXPORT QubesOS KEYS", // [ΛИ0ИΞR0]
                onPressed: _showQubesKeys,
              ),
              LongOutlinedButton(
                text: "EXPORT [ИΞR0] KEYS", // [ΛИ0ИΞR0]
                onPressed: _showNeroKeys,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Wrap _seedWidget() {
    return Wrap(
      children: (useLegacy ? legacySeed : seed).map((e) {
        return TinyCard(e);
      }).toList(),
    );
  }

  void _changeHeight() {
    final tCtrl = TextEditingController(text: restoreHeight.toString());
    Alert(
      singleBody: LabeledTextInput(label: "Update restore height", ctrl: tCtrl),
      cancelable: true,
      callback: () {
        final i = int.tryParse(tCtrl.text);
        if (i == null) return;
        MONERO_Wallet_setRefreshFromBlockHeight(
          walletPtr!,
          refresh_from_block_height: i,
        );
        setState(() {
          restoreHeight = i;
        });
        Navigator.of(context).pop();
      },
      callbackText: "Set",
    ).show(context);
  }
}
