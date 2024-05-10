import 'dart:typed_data';

import 'package:bytewords/bytewords.dart';
import 'package:flutter/material.dart';
import 'package:xmruw/pages/scanner/process_ur.dart';
import 'package:xmruw/tools/show_alert.dart';
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

    final splTxt = codeCtrl.text.split(":");
    if (splTxt.length != 2) {
      Alert(
        title: "Invalid code provided",
        cancelable: true,
      ).show(context);
      return;
    }
    Uint8List? data;
    try {
      data = bytewordsDecode(
        BytewordsStyle.minimal,
        splTxt[1],
      );
    } catch (e) {
      Alert(
        title: "bytewords error: $e",
        cancelable: true,
      ).show(context);
      return;
    }
    setState(() {
      isProcessing = true;
    });

    await processUr(context, splTxt[0], data);
    setState(() {
      isProcessing = false;
    });
  }
}
