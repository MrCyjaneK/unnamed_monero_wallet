import 'package:anonero/pages/setup/mnemonic_seed.dart';
import 'package:anonero/pages/setup/passphrase_encryption.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/proxy_button.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/material.dart';

enum SetupNodeConnectionFlag { createWallet, restoreWalletSeed }

class SetupNodeConnection extends StatefulWidget {
  const SetupNodeConnection({super.key, required this.flag});

  final SetupNodeConnectionFlag flag;

  @override
  State<SetupNodeConnection> createState() => _SetupNodeConnectionState();

  static void push(BuildContext context, SetupNodeConnectionFlag flag) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return SetupNodeConnection(flag: flag);
      },
    ));
  }
}

class _SetupNodeConnectionState extends State<SetupNodeConnection> {
  final nodeCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SetupLogo(title: "NODE CONNECTION"),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  LabeledTextInput(
                    // Called to rebuild the UI and make the button switch
                    // Connect <-> Skip
                    onEdit: () {
                      setState(() {});
                    },
                    ctrl: nodeCtrl,
                    label: "NODE",
                    hintText: "http://address.onion:port",
                  ),
                  LabeledTextInput(
                    ctrl: usernameCtrl,
                    label: "USERNAME",
                    hintText: "(optional)",
                  ),
                  LabeledTextInput(
                    ctrl: passwordCtrl,
                    label: "PASSWORD",
                    hintText: "(optional)",
                  ),
                  const SizedBox(height: 32),
                  const ProxyButton(),
                ],
              ),
            ),
          ),
          LongOutlinedButton(
            text: nodeCtrl.text == "" ? "Skip" : "Connect",
            onPressed: _nextScreenSafe,
          ),
        ],
      ),
    );
  }

  void _nextScreenSafe() {
    if (nodeCtrl.text.isEmpty) {
      Alert(
        title: "Creating offline wallet",
        cancelable: true,
        callback: _nextScreen,
      ).show(context);
    } else {
      _nextScreen();
    }
  }

  void _nextScreen() {
    switch (widget.flag) {
      case SetupNodeConnectionFlag.createWallet:
        PassphraseEncryption.push(
          context,
          PassphraseEncryptionFlag.createWallet,
        );
      case SetupNodeConnectionFlag.restoreWalletSeed:
        MnemonicSeed.push(context);
    }
  }
}
