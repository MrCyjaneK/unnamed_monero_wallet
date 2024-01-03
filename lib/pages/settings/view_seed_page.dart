import 'dart:convert';

import 'package:anonero/const/app_name.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/padded_element.dart';
import 'package:anonero/widgets/primary_label.dart';
import 'package:anonero/widgets/qr_code.dart';
import 'package:anonero/widgets/tiny_card.dart';
import 'package:flutter/material.dart';
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

  late final seed = ['unsupported'];

  bool useLegacy = true;

  void _toggleSeed() {
    setState(() {
      useLegacy = !useLegacy;
    });
  }

  void _showNeroKeys() {
    final data = const JsonEncoder.withIndent('   ').convert({
      "version": 0,
      "primaryAddress":
          MONERO_Wallet_address(walletPtr!, accountIndex: 0, addressIndex: 0),
      "privateViewKey": MONERO_Wallet_secretViewKey(walletPtr!),
      "restoreHeight": MONERO_Wallet_getRefreshFromBlockHeight(walletPtr!),
    });
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

  String viewKey = MONERO_Wallet_publicViewKey(walletPtr!);
  String spendKey = MONERO_Wallet_secretSpendKey(walletPtr!);
  int restoreHeight = MONERO_Wallet_getRefreshFromBlockHeight(walletPtr!);

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
                onTap: _toggleSeed,
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
              PaddedElement(child: SelectableText(restoreHeight.toString())),
              const Divider(),
              LongOutlinedButton(
                text: "EXPORT $nero KEYS",
                onPressed: _showNeroKeys,
              )
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
}
