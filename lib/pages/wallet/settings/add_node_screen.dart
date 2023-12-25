import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/proxy_button.dart';
import 'package:flutter/material.dart';

class AddNodeScreen extends StatefulWidget {
  const AddNodeScreen({super.key});
  @override
  State<AddNodeScreen> createState() => _AddNodeScreenState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const AddNodeScreen();
      },
    ));
  }
}

class _AddNodeScreenState extends State<AddNodeScreen> {
  final nodeCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Node"),
      ),
      body: Column(
        children: [
          LabeledTextInput(
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
          const Spacer(),
          const LongOutlinedButton(
            text: "ADD NODE",
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
