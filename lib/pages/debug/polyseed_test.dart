import 'dart:io';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/wallet_manager.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';

class PolyseedCompatTestDebug extends StatefulWidget {
  const PolyseedCompatTestDebug({super.key});

  @override
  State<PolyseedCompatTestDebug> createState() =>
      _PolyseedCompatTestDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const PolyseedCompatTestDebug();
      },
    ));
  }
}

class _PolyseedCompatTestDebugState extends State<PolyseedCompatTestDebug> {
  String? path;

  @override
  void initState() {
    getPolyseedTestPath().then((value) {
      setState(() {
        path = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Polyseed Compat"),
        ),
        body: const LinearProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polyseed Compat"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            (Directory(path!).existsSync())
                ? LongOutlinedButton(
                    text: "Delete temp dir",
                    onPressed: () {
                      Directory(path!).deleteSync(recursive: true);
                      setState(() {});
                    },
                  )
                : LongOutlinedButton(
                    text: "Create wallets",
                    onPressed: _createWallets,
                  ),
            ..._buildWidgets(pWallets),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWidgets(Map<String, monero.wallet?> ps) {
    List<Widget> list = [];
    ps.forEach((key, value) {
      if (value == null) {
        list.add(Text("$key: null"));
        return;
      }
      list.add(
        ExpansionTile(
          collapsedBackgroundColor:
              (pSeeds[key] != monero.Wallet_getPolyseed(value, passphrase: ''))
                  ? Theme.of(context).colorScheme.error
                  : null,
          title: Text(key),
          children: [
            SelectableText("polyseed (Wallet::createPolyseed): ${pSeeds[key]}"),
            SelectableText(
                "polyseed (Wallet::getPolyseed): ${monero.Wallet_getPolyseed(value, passphrase: '')}"),
            SelectableText("address: ${monero.Wallet_address(value)}"),
            SelectableText("error: ${pErrors[key]}")
          ],
        ),
      );
    });
    return list;
  }

  Map<String, monero.wallet?> pWallets = {
    "Czech": null,
    "čeština": null,
    "English": null,
    "Spanish": null,
    "español": null,
    "French": null,
    "français": null,
    "Italian": null,
    "italiano": null,
    "Japanese": null,
    "日本語": null,
    "Korean": null,
    "한국어": null,
    "Portuguese": null,
    "português": null,
    "Chinese (Simplified)": null,
    "中文(简体)": null,
    "Chinese (Traditional)": null,
    "中文(繁體)": null,
  };

  Map<String, String?> pErrors = {
    "Czech": null,
    "čeština": null,
    "English": null,
    "Spanish": null,
    "español": null,
    "French": null,
    "français": null,
    "Italian": null,
    "italiano": null,
    "Japanese": null,
    "日本語": null,
    "Korean": null,
    "한국어": null,
    "Portuguese": null,
    "português": null,
    "Chinese (Simplified)": null,
    "中文(简体)": null,
    "Chinese (Traditional)": null,
    "中文(繁體)": null,
  };

  Map<String, String?> pSeeds = {
    "Czech": null,
    "čeština": null,
    "English": null,
    "Spanish": null,
    "español": null,
    "French": null,
    "français": null,
    "Italian": null,
    "italiano": null,
    "Japanese": null,
    "日本語": null,
    "Korean": null,
    "한국어": null,
    "Portuguese": null,
    "português": null,
    "Chinese (Simplified)": null,
    "中文(简体)": null,
    "Chinese (Traditional)": null,
    "中文(繁體)": null,
  };

  Future<void> _createWallets() async {
    Directory(path!).createSync();
    for (var k in pWallets.keys) {
      final ps = monero.Wallet_createPolyseed(language: k);
      setState(() {
        pSeeds[k] = ps;
        pWallets[k] = monero.WalletManager_createWalletFromPolyseed(
          wmPtr,
          path:
              "${path!}/monero_wallet-${DateTime.now().microsecondsSinceEpoch}",
          password: 'p',
          mnemonic: ps,
          seedOffset: '',
          newWallet: true,
          restoreHeight: 0,
          kdfRounds: 1,
        );
        pErrors[k] = monero.Wallet_errorString(pWallets[k]!);
      });
    }
  }
}
