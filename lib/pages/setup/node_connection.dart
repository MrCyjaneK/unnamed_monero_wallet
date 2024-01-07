import 'package:anonero/pages/setup/mnemonic_seed.dart';
import 'package:anonero/pages/setup/passphrase_encryption.dart';
import 'package:anonero/pages/setup/view_only_keys.dart';
import 'package:anonero/tools/node.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/proxy_button.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/material.dart';

enum SetupNodeConnectionFlag {
  createWallet,
  restoreWalletSeed,
  restoreWalletNero
}

class SetupNodeConnection extends StatefulWidget {
  const SetupNodeConnection({super.key, required this.flag});

  final SetupNodeConnectionFlag flag;

  @override
  State<SetupNodeConnection> createState() => _SetupNodeConnectionState();

  static void push(BuildContext context, SetupNodeConnectionFlag flag) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return SetupNodeConnection(flag: flag);
      },
    ));
  }
}

class _SetupNodeConnectionState extends State<SetupNodeConnection> {
  int id = NodeStore.getUniqueId();
  final nodeCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  void initState() {
    NodeStore.getCurrentNode().then((node) {
      if (node == null) return;
      setState(() {
        id = node.id;
        nodeCtrl.text = node.address;
        usernameCtrl.text = node.username;
        passwordCtrl.text = passwordCtrl.text;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SetupLogo(title: "NODE CONNECTION"),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  LabeledTextInput(
                    // Called to rebuild the UI and make the button switch
                    // Connect <-> Skip
                    onEdit: () {
                      setState(() {});
                    },
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
                ],
              ),
            ),
          ),
          LongOutlinedButton(
            text: (widget.flag != SetupNodeConnectionFlag.restoreWalletNero &&
                    nodeCtrl.text == "")
                ? "Skip"
                : "Connect",
            onPressed:
                (widget.flag == SetupNodeConnectionFlag.restoreWalletNero &&
                        nodeCtrl.text == "")
                    ? null
                    : _nextScreenSafe,
          ),
        ],
      ),
    );
  }

  void _nextScreenSafe() async {
    if (nodeCtrl.text.isEmpty) {
      Alert(
        title: "Creating offline wallet",
        cancelable: true,
        callback: _nextScreen,
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
        id: id,
      ),
      current: true,
    );
    _nextScreen();
  }

  void _nextScreen() {
    switch (widget.flag) {
      case SetupNodeConnectionFlag.createWallet:
        PassphraseEncryption.push(
          context,
          PassphraseEncryptionFlag.createWallet,
        );
      case SetupNodeConnectionFlag.restoreWalletSeed:
        MnemonicSeed.push(context);
      case SetupNodeConnectionFlag.restoreWalletNero:
        ViewOnlyKeysSetup.push(context);
    }
  }
}
