import 'package:anonero/pages/pin_screen.dart';
import 'package:anonero/pages/setup/passphrase_encryption.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/material.dart';

class ViewOnlyKeysSetup extends StatefulWidget {
  const ViewOnlyKeysSetup({super.key});

  @override
  State<ViewOnlyKeysSetup> createState() => _ViewOnlyKeysSetupState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ViewOnlyKeysSetup();
      },
    ));
  }
}

class _ViewOnlyKeysSetupState extends State<ViewOnlyKeysSetup> {
  final primaryAddressCtrl = TextEditingController();
  final privateViewKeyCtrl = TextEditingController();
  final restoreHeightCtrl = TextEditingController();

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SetupLogo(title: "VIEW ONLY KEYS"),
            LabeledTextInput(
              label: "PRIMARY ADDRESS",
              ctrl: primaryAddressCtrl,
              onEdit: _rebuild,
            ),
            LabeledTextInput(
              label: "SECRET VIEW KEY",
              ctrl: privateViewKeyCtrl,
              onEdit: _rebuild,
            ),
            LabeledTextInput(
              label: "RESTORE HEIGHT",
              ctrl: restoreHeightCtrl,
              onEdit: _rebuild,
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          LongOutlinedButton(text: "Next", onPressed: _continue),
    );
  }

  void _continue() async {
    PinScreen.push(
      context,
      PinScreenFlag.restoreWalletNero,
      passphrase: '',
      restoreData: RestoreData(
        seed: '',
        restoreHeight: int.tryParse(restoreHeightCtrl.text) ?? 0,
        restoreType: RestoreType.legacy,
        primaryAddress: primaryAddressCtrl.text,
        privateViewKey: privateViewKeyCtrl.text,
      ),
    );
  }
}
