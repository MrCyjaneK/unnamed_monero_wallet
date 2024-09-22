import 'package:flutter/material.dart';
import 'package:monero/monero.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';

class ScannerTextOnly extends StatefulWidget {
  const ScannerTextOnly({super.key});
  static Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ScannerTextOnly();
      },
    ));
  }

  static void pushReplace(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const ScannerTextOnly();
      },
    ));
  }

  @override
  State<ScannerTextOnly> createState() => _ScannerTextOnlyState();
}

class _ScannerTextOnlyState extends State<ScannerTextOnly> {
  final codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LabeledTextInput(
        label: "Input UR code",
        ctrl: codeCtrl,
        minLines: 10,
        maxLines: 300,
      ),
      bottomNavigationBar: LongOutlinedButton(
        text: "Continue",
        onPressed: _processUr,
      ),
    );
  }

  bool isProcessing = false;
  void _processUr() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
    });
    final splTxt = codeCtrl.text.split(":");
    if (splTxt.length <= 1) {
      Alert(
        title: "Invalid code provided",
        cancelable: true,
      ).show(context);
      return;
    }
    final tag = splTxt[1].split("/")[0];
    switch (tag) {
      case "xmr-output":
        Wallet_importOutputsUR(walletPtr!, codeCtrl.text);
    }
    final status = Wallet_status(walletPtr!);
    if (status != 0) {
      final errorString = Wallet_errorString(walletPtr!);
      await Alert(
              title: "Error",
              singleBody: SelectableText(errorString),
              cancelable: true)
          .show(context);
    }

    setState(() {
      isProcessing = false;
    });
  }
}
