import 'package:anonero/pages/setup/passphrase_encryption.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/material.dart';

class MnemonicSeed extends StatefulWidget {
  const MnemonicSeed({super.key});

  @override
  State<MnemonicSeed> createState() => _MnemonicSeedState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const MnemonicSeed();
      },
    ));
  }
}

class _MnemonicSeedState extends State<MnemonicSeed> {
  final seedCtrl = TextEditingController();
  final heightCtrl = TextEditingController();

  List<String> seed = [];
  void _rebuildSeed() {
    setState(() {
      seed = seedCtrl.text.replaceAllMapped(RegExp(r'\b\s+\b'), (match) {
        return '"${match.group(0)}"';
      }).split(' ');
    });
  }

  void _rebuildHeight() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SetupLogo(title: "MNEMONIC SEED"),
          LabeledTextInput(
            label: "ENTER SEED",
            ctrl: seedCtrl,
            minLines: 8,
            maxLines: 8,
            onEdit: _rebuildSeed,
          ),
          if (seed.length > 16 + 1)
            LabeledTextInput(
              label: "RESTORE HEIGHT",
              ctrl: heightCtrl,
              onEdit: _rebuildHeight,
            ),
          const Spacer(),
          _continueButton()
        ],
      ),
    );
  }

  void _nextPage() {
    PassphraseEncryption.push(
      context,
      PassphraseEncryptionFlag.restoreWalletSeed,
    );
  }

  Widget _continueButton() {
    if (seed.length == 16) {
      return LongOutlinedButton(text: "Next", onPressed: _nextPage);
    }
    if (seed.length == 25 && num.tryParse(heightCtrl.text) != null) {
      return LongOutlinedButton(text: "Next", onPressed: _nextPage);
    }
    return Container();
  }
}
