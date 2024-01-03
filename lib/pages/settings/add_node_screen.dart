import 'package:anonero/tools/node.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/proxy_button.dart';
import 'package:flutter/material.dart';

class AddNodeScreen extends StatefulWidget {
  const AddNodeScreen({super.key});
  @override
  State<AddNodeScreen> createState() => _AddNodeScreenState();

  static Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
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

  void _addNode() {
    if (nodeCtrl.text.isEmpty) {
      Alert(
        title: "No host provided",
        cancelable: true,
      ).show(context);
      return;
    }
    String nodeUrl = nodeCtrl.text;
    if (!nodeUrl.toLowerCase().startsWith('http://') &&
        !nodeUrl.toLowerCase().startsWith("https://")) {
      nodeUrl = "http://$nodeUrl";
    }
    if (Uri.tryParse(nodeUrl) == null) {
      Alert(title: "Invalid node address").show(context);
      return;
    }
    NodeStore.saveNode(
      Node(
        address: nodeUrl,
        username: usernameCtrl.text,
        password: passwordCtrl.text,
        id: NodeStore.getUniqueId(),
      ),
      current: false,
    );
    Navigator.of(context).pop();
  }

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
          LongOutlinedButton(
            text: "ADD NODE",
            onPressed: _addNode,
          ),
        ],
      ),
    );
  }
}
