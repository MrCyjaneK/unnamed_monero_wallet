import 'dart:convert';

import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:xmruw/widgets/setup_logo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PassphraseEncryptionFlag { createWallet, restoreWalletSeed }

// NOTE: Use global context if this ever becomes stateful widget in function
// _nextPage
class PassphraseEncryption extends StatelessWidget {
  PassphraseEncryption({super.key, required this.flag, this.restoreData});
  final RestoreData? restoreData;
  final PassphraseEncryptionFlag flag;

  final pass1Ctrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SetupLogo(title: "PASSPHRASE ENCRYPTION"),
                  if (kDebugMode)
                    SelectableText(const JsonEncoder.withIndent('    ')
                        .convert(restoreData)),
                  LabeledTextInput(
                    label: "ENTER PASSPHRASE",
                    hintText: "",
                    ctrl: pass1Ctrl,
                  ),
                  LabeledTextInput(
                    label: "CONFIRM PASSPHRASE",
                    hintText: "",
                    ctrl: pass2Ctrl,
                  ),
                  const SizedBox(height: 16),
                  const Text("Enter your seed passphrase"),
                  const SizedBox(height: 16),
                  SelectableText(
                    "NOTE: Passphrase is required\n"
                    "to restore from\n"
                    "seed or backup file",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  )
                ],
              ),
            ),
          ),
          LongOutlinedButton(
            text: "Next",
            onPressed: () => _nextPage(context),
          )
        ],
      ),
    );
  }

  void _createWallet(BuildContext c) {
    if (!_isPassphraseValid()) {
      Alert(title: _passphraseInvalidReason() ?? "", cancelable: true).show(c);
      return;
    }
    PinScreen.push(c, PinScreenFlag.createWallet, passphrase: pass1Ctrl.text);
  }

  void _restoreWalletSeed(BuildContext c) {
    if (!_isPassphraseValid()) {
      Alert(title: _passphraseInvalidReason() ?? "", cancelable: true).show(c);
      return;
    }
    PinScreen.push(
      c,
      PinScreenFlag.restoreWalletSeed,
      passphrase: pass1Ctrl.text,
      restoreData: restoreData!,
    );
  }

  void _nextPage(BuildContext c) {
    switch (flag) {
      case PassphraseEncryptionFlag.createWallet:
        _createWallet(c);
      case PassphraseEncryptionFlag.restoreWalletSeed:
        _restoreWalletSeed(c);
    }
  }

  bool _isPassphraseValid() {
    return _passphraseInvalidReason() == null;
  }

  String? _passphraseInvalidReason() {
    //if (pass1Ctrl.text.isEmpty) return "Passphrase is empty";
    if (pass1Ctrl.text != pass2Ctrl.text) return "Passphrases doesn't match";
    return null;
  }

  static void push(BuildContext context, PassphraseEncryptionFlag flag,
      {RestoreData? restoreData}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PassphraseEncryption(flag: flag, restoreData: restoreData);
      },
    ));
  }
}

enum RestoreType { legacy }

class RestoreData {
  RestoreData({
    required this.seed,
    required this.restoreHeight,
    required this.restoreType,
    this.privateViewKey,
    this.primaryAddress,
  });
  final String seed;
  final int? restoreHeight;
  final RestoreType restoreType;
  final String? privateViewKey;
  final String? primaryAddress;
  Map<String, dynamic> toJson() {
    return {
      "seed": seed,
      "restoreHeight": restoreHeight,
      "restoreType": restoreType.toString(),
      "privateViewKey": privateViewKey,
      "primaryAddress": primaryAddress,
    };
  }
}
