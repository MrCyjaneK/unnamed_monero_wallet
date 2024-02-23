import 'dart:convert';
import 'dart:io';

import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/pages/scanner/view_only_scanner.dart';
import 'package:xmruw/pages/setup/passphrase_encryption.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:xmruw/widgets/setup_logo.dart';
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
            const SizedBox(height: 32),
            IconButton(
              iconSize: 48,
              onPressed: () async {
                final keysCtrl = TextEditingController();
                await Alert(
                    singleBody: LabeledTextInput(
                      label: "Exported QubesOS keys",
                      ctrl: keysCtrl,
                    ),
                    callback: () {
                      Navigator.of(context).pop();
                    }).show(context);
                final data = json.decode(keysCtrl.text);
                setState(() {
                  primaryAddressCtrl.text = data['primaryAddress'].toString();
                  privateViewKeyCtrl.text = data['privateViewKey'].toString();
                  restoreHeightCtrl.text = data['restoreHeight'].toString();
                });
              },
              icon: const Icon(Icons.code),
            ),
            if (Platform.isAndroid)
              IconButton(
                iconSize: 48,
                onPressed: () async {
                  await ViewOnlyScannerPage.push(context);
                  if (viewOnlyKeysLastScanned['primaryAddress'] == null) return;
                  setState(() {
                    primaryAddressCtrl.text =
                        viewOnlyKeysLastScanned['primaryAddress'].toString();
                    privateViewKeyCtrl.text =
                        viewOnlyKeysLastScanned['privateViewKey'].toString();
                    restoreHeightCtrl.text =
                        viewOnlyKeysLastScanned['restoreHeight'].toString();
                  });
                },
                icon: const Icon(Icons.crop_free_sharp),
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
