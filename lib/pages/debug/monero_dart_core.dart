import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/tools/wallet_manager.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';

class MoneroDartCore extends StatefulWidget {
  const MoneroDartCore({super.key});

  @override
  State<MoneroDartCore> createState() => _MoneroDartCoreState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const MoneroDartCore();
      },
    ));
  }
}

class _MoneroDartCoreState extends State<MoneroDartCore> {
  final pathCtrl = TextEditingController(
    text: '/data/data/net.mrcyjanek.xmruw/files/wallet',
  );
  final passwordCtrl = TextEditingController(text: 'test');
  final networkTypeCtrl = TextEditingController(text: '0');

  String result = "NOTE: There are no safety checks, you may crash the app.";
  monero.wallet? wallet = walletPtr;

  void _call() {
    try {
      final p = monero.WalletManager_createWallet(
        wmPtr,
        path: pathCtrl.text,
        password: passwordCtrl.text,
      );
      setState(() {
        wallet = p;
        result = p.toString();
      });
    } catch (e) {
      setState(() {
        result = e.toString();
      });
    }
  }

  void _callAddress(int accountIndex, int addressIndex) {
    try {
      final p = monero.Wallet_address(
        wallet!,
        accountIndex: accountIndex,
        addressIndex: addressIndex,
      );
      setState(() {
        result = p.toString();
      });
    } catch (e) {
      setState(() {
        result = e.toString();
      });
    }
  }

  int status = -1;

  void _status() {
    try {
      final p = monero.Wallet_status(wallet!);
      setState(() {
        result = p.toString();
        status = p;
      });
    } catch (e) {
      setState(() {
        result = e.toString();
      });
    }
  }

  void _errorString() {
    try {
      final p = monero.Wallet_errorString(wallet!);
      setState(() {
        result = p.toString();
      });
    } catch (e) {
      setState(() {
        result = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("monero.dart"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LabeledTextInput(label: "(arg0) wallet path", ctrl: pathCtrl),
            LabeledTextInput(label: "(arg1) password", ctrl: passwordCtrl),
            LabeledTextInput(
              label: "(arg2) networkType (must int.Parse)",
              ctrl: networkTypeCtrl,
            ),
            LongOutlinedButton(text: "Call", onPressed: _call),
            LongOutlinedButton(
                text: "Status", onPressed: wallet == null ? null : _status),
            LongOutlinedButton(
                text: "ErrorString",
                onPressed: wallet == null ? null : _errorString),
            LongOutlinedButton(
                text: "Address(0,0)",
                onPressed: (wallet == null && status == 0)
                    ? null
                    : () => _callAddress(0, 0)),
            LongOutlinedButton(
                text: "Address(0,1)",
                onPressed: (wallet == null && status == 0)
                    ? null
                    : () => _callAddress(0, 1)),
            SelectableText(result)
          ],
        ),
      ),
    );
  }
}
