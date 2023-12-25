import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class ProxySettings extends StatelessWidget {
  ProxySettings({super.key});

  final serverCtrl = TextEditingController(text: "127.0.0.1");
  final torPortCtrl = TextEditingController(text: "9050");
  final i2pPortCtrl = TextEditingController(text: "4447");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proxy Settings"),
      ),
      body: Column(
        children: [
          LabeledTextInput(
            label: "SERVER",
            hintText: "127.0.0.1",
            ctrl: serverCtrl,
          ),
          LabeledTextInput(
            label: "TOR PORT",
            hintText: "9050",
            ctrl: torPortCtrl,
          ),
          LabeledTextInput(
            label: "I2P PORT",
            hintText: "4447",
            ctrl: i2pPortCtrl,
          ),
          const Spacer(),
          LongOutlinedButton(
            text: "SET",
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return ProxySettings();
      },
    ));
  }
}
