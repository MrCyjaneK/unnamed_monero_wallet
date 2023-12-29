import 'package:anonero/tools/proxy.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class ProxySettings extends StatefulWidget {
  const ProxySettings({super.key});

  @override
  State<ProxySettings> createState() => _ProxySettingsState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ProxySettings();
      },
    ));
  }
}

class _ProxySettingsState extends State<ProxySettings> {
  final serverCtrl = TextEditingController();
  final torPortCtrl = TextEditingController();
  final i2pPortCtrl = TextEditingController();

  @override
  void initState() {
    ProxyStore.getProxy().then((value) {
      setState(() {
        serverCtrl.text = value.address;
        torPortCtrl.text = value.torPort.toString();
        i2pPortCtrl.text = value.i2pPort.toString();
      });
    });
    super.initState();
  }

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
            onPressed: _set,
          )
        ],
      ),
    );
  }

  void _set() async {
    final torPort = int.tryParse(torPortCtrl.text);
    final i2pPort = int.tryParse(i2pPortCtrl.text);
    if (torPort == null || i2pPort == null) {
      Alert(title: "Invalid port", cancelable: true).show(context);
      return;
    }
    ProxyStore.setProxy(
      ProxyStore(address: serverCtrl.text, torPort: torPort, i2pPort: i2pPort),
    );
    Navigator.of(context).pop();
  }
}
