import 'package:flutter/material.dart';
import 'package:monero/monero.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/bottom_bar.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';

enum Page { sign, verify }

class CryptoStuff extends StatefulWidget {
  const CryptoStuff({super.key});
  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const CryptoStuff();
      },
    ));
  }

  @override
  State<CryptoStuff> createState() => _CryptoStuffState();
}

class _CryptoStuffState extends State<CryptoStuff> {
  Page page = Page.sign;

  late final PageController pageController =
      PageController(initialPage: page.index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView(
        controller: pageController,
        children: const [
          CryptoSign(),
          CryptoVerify(),
        ],
        onPageChanged: (value) {
          setState(() {
            page = Page.values[value];
          });
        },
      ),
      bottomNavigationBar: BottomBar(
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedIndex: page.index,
        onTap: (int index) {
          setState(() => page = Page.values[index]);
          pageController.jumpToPage(index);
        },
        items: <BottomBarItem>[
          BottomBarItem(
            icon: const Icon(Icons.no_encryption),
            title: const Text('Sign'),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          BottomBarItem(
            icon: const Icon(Icons.enhanced_encryption),
            title: const Text('Verify'),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class CryptoSign extends StatefulWidget {
  const CryptoSign({super.key});

  @override
  State<CryptoSign> createState() => _CryptoSignState();
}

class _CryptoSignState extends State<CryptoSign> {
  final messageCtrl = TextEditingController();
  final addressCtrl = TextEditingController(
    text: MONERO_Wallet_address(walletPtr!),
  );

  String result = "";

  void sign() {
    final msg = MONERO_Wallet_signMessage(
      walletPtr!,
      message: messageCtrl.text,
      address: addressCtrl.text,
    );
    final status = MONERO_Wallet_status(walletPtr!);
    if (status != 0) {
      final errstr = MONERO_Wallet_errorString(walletPtr!);
      Alert(
        title: "Unable to sign: $errstr",
        cancelable: true,
      ).show(context);
    }
    setState(() {
      result = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LabeledTextInput(
          label: "Message",
          ctrl: messageCtrl,
          minLines: 2,
        ),
        LabeledTextInput(label: "Address", ctrl: addressCtrl),
        LongOutlinedButton(text: "Sign", onPressed: sign),
        SelectableText(result),
      ],
    );
  }
}

class CryptoVerify extends StatefulWidget {
  const CryptoVerify({super.key});

  @override
  State<CryptoVerify> createState() => _CryptoVerifyState();
}

class _CryptoVerifyState extends State<CryptoVerify> {
  final messageCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final signatureCtrl = TextEditingController();

  void verify() {
    final v = MONERO_Wallet_verifySignedMessage(
      walletPtr!,
      message: messageCtrl.text,
      address: addressCtrl.text,
      signature: signatureCtrl.text,
    );
    if (v == false) {
      Alert(
        title: "Signature verification failed",
        cancelable: true,
      ).show(context);
    } else {
      Alert(
        title: "Signature match",
        cancelable: true,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          LabeledTextInput(
            label: "Message",
            ctrl: messageCtrl,
            minLines: 2,
          ),
          LabeledTextInput(label: "Address", ctrl: addressCtrl),
          LabeledTextInput(
            label: "Signature",
            ctrl: signatureCtrl,
            minLines: 2,
          ),
          LongOutlinedButton(
            text: "Verify",
            onPressed: verify,
          )
        ],
      ),
    );
  }
}
