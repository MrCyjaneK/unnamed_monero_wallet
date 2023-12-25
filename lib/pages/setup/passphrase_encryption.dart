import 'package:anonero/pages/pin_screen.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/material.dart';

enum PassphraseEncryptionFlag { createWallet, restoreWalletSeed }

// NOTE: Use global context if this ever becomes stateful widget in function
// _nextPage
class PassphraseEncryption extends StatelessWidget {
  PassphraseEncryption({super.key, required this.flag});

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

  void _nextPage(BuildContext c) {
    switch (flag) {
      case PassphraseEncryptionFlag.createWallet:
        if (!_isPassphraseValid()) {
          Alert(title: _passphraseInvalidReason() ?? "", cancelable: true)
              .show(c);
          return;
        }
        PinScreen.push(c, PinScreenFlag.createWallet);
      case PassphraseEncryptionFlag.restoreWalletSeed:
        if (!_isPassphraseValid()) {
          Alert(title: _passphraseInvalidReason() ?? "", cancelable: true)
              .show(c);
          return;
        }
        PinScreen.push(c, PinScreenFlag.restoreWalletSeed);
    }
  }

  bool _isPassphraseValid() {
    return _passphraseInvalidReason() == null;
  }

  String? _passphraseInvalidReason() {
    if (pass1Ctrl.text.isEmpty) return "Passphrase is empty";
    if (pass1Ctrl.text != pass2Ctrl.text) return "Passphrases doesn't match";
    return null;
  }

  static void push(BuildContext context, PassphraseEncryptionFlag flag) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PassphraseEncryption(flag: flag);
      },
    ));
  }
}
