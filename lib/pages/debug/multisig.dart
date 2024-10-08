import 'dart:io';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_manager.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';

const preambleText = """
Multisig... it is terrible, documentation doesn't exist, is incomplete, or focuses on explaining how to use it using MMS (which I had trouble setting up - so no, xmruw will not use it as it currently is), and not on how it works.

So here you can see some experiments with multisig... i have no idea what I am doing.
""";

class MultisigDebug extends StatefulWidget {
  const MultisigDebug({super.key});

  @override
  State<MultisigDebug> createState() => _MultisigDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const MultisigDebug();
      },
    ));
  }
}

class _MultisigDebugState extends State<MultisigDebug> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("multisig"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _preamble(),
              ..._multisigDetails(),
              ..._multisig(),
              ..._getMultisigInfo(),
              ..._makeMultisig(),
              ..._exchangeMultisigKeys(),
              ..._exportMultisigImages(),
              ..._importMultisigImages(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preamble() {
    return const SelectableText(preambleText);
  }

  monero.MultisigState? mstate;

  List<Widget> _multisigDetails() {
    if (mstate == null) {
      return [
        const Divider(),
        const Text("Unable to fetch multisig data - mstate is null"),
      ];
    }
    return [
      const Divider(),
      SelectableText("isMultisig: ${monero.MultisigState_isMultisig(mstate!)}"),
      SelectableText("isReady: ${monero.MultisigState_isReady(mstate!)}"),
      SelectableText("threshold: ${monero.MultisigState_threshold(mstate!)}"),
      SelectableText("total: ${monero.MultisigState_total(mstate!)}"),
    ];
  }

  void _multisigInit() {
    setState(() {
      mstate = monero.Wallet_multisig(walletPtr!);
    });
    checkWalletError();
  }

  List<Widget> _multisig() {
    return [
      const Divider(),
      const SelectableText("Get a pointer to `MultisigState`. Possibly empty."),
      LongOutlinedButton(
        text: "Wallet_multisig",
        onPressed: _multisigInit,
      ),
    ];
  }

  String? msigInfo;

  void _getMultisigInfoInit() {
    setState(() {
      msigInfo = monero.Wallet_getMultisigInfo(walletPtr!);
    });
    checkWalletError();
  }

  void _getMultisigInfoInitThrowaway() async {
    final p = "${await getMainWalletPath()}.temp";
    if (File(p).existsSync()) {
      File(p).deleteSync();
    }
    if (File("$p.keys").existsSync()) {
      File("$p.keys").deleteSync();
    }
    final wptr =
        monero.WalletManager_createWallet(wmPtr, path: p, password: "");
    checkWalletError(wptr: wptr);
    setState(() {
      msigInfo = monero.Wallet_getMultisigInfo(wptr);
    });
    checkWalletError(wptr: wptr);
  }

  List<Widget> _getMultisigInfo() {
    return [
      const Divider(),
      const SelectableText("Monero::Wallet::getMultisigInfo()"),
      SelectableText(msigInfo ?? "msigInfo is null"),
      LongOutlinedButton(
        text: "Wallet_getMultisigInfo",
        onPressed: _getMultisigInfoInit,
      ),
      LongOutlinedButton(
        text: "Wallet_getMultisigInfo (throwaway)",
        onPressed: _getMultisigInfoInitThrowaway,
      ),
    ];
  }

  void _makeMultisigInit() {
    final shoudBeCount = int.tryParse(makeMultisigCount.text);
    if (shoudBeCount == null) return;
    if (shoudBeCount != makeMultisigCtrls.length) {
      setState(() {
        makeMultisigCtrls = List.generate(
          shoudBeCount,
          (index) => TextEditingController(),
        );
      });
      return;
    }
    setState(() {
      makeMultisigInfo = monero.Wallet_makeMultisig(
        walletPtr!,
        info: makeMultisigCtrls.map((e) => e.text).toList(),
        threshold: int.parse(makeMultisigThresholdCtrl.text),
      );
    });
    checkWalletError();
  }

  List<TextEditingController> makeMultisigCtrls = [];
  TextEditingController makeMultisigCount = TextEditingController(text: '1');
  TextEditingController makeMultisigThresholdCtrl =
      TextEditingController(text: '1');
  String? makeMultisigInfo;

  List<Widget> _makeMultisig() {
    final ret = [
      const Divider(),
      const SelectableText("Monero::Wallet::makeMultisig()"),
      SelectableText(makeMultisigInfo ?? "makeMultisigInfo is null"),
      LabeledTextInput(label: "Multisig Count", ctrl: makeMultisigCount),
      LabeledTextInput(label: "Threshold", ctrl: makeMultisigThresholdCtrl),
    ];

    for (var i = 0; i < makeMultisigCtrls.length; i++) {
      ret.add(
        LabeledTextInput(
          label: "Multisig info #$i",
          ctrl: makeMultisigCtrls[i],
        ),
      );
    }

    ret.add(LongOutlinedButton(
      text: "Wallet_makeMultisig",
      onPressed: _makeMultisigInit,
    ));
    return ret;
  }

  void _exchangeMultisigKeysInit() {
    final shoudBeCount = int.tryParse(exchangeMultisigKeysCount.text);
    if (shoudBeCount == null) return;
    if (shoudBeCount != exchangeMultisigKeysCtrls.length) {
      setState(() {
        exchangeMultisigKeysCtrls = List.generate(
          shoudBeCount,
          (index) => TextEditingController(),
        );
      });
      return;
    }
    setState(() {
      exchangeMultisigKeysInfo = monero.Wallet_exchangeMultisigKeys(
        walletPtr!,
        info: exchangeMultisigKeysCtrls.map((e) => e.text).toList(),
        force_update_use_with_caution: exchangeMultisigKeysForceUpdate,
      );
    });
    checkWalletError();
  }

  bool exchangeMultisigKeysForceUpdate = false;
  List<TextEditingController> exchangeMultisigKeysCtrls = [];
  TextEditingController exchangeMultisigKeysCount =
      TextEditingController(text: '1');
  TextEditingController exchangeMultisigKeysThresholdCtrl =
      TextEditingController(text: '1');
  String? exchangeMultisigKeysInfo;

  List<Widget> _exchangeMultisigKeys() {
    final ret = [
      const Divider(),
      const SelectableText("Monero::Wallet::exchangeMultisigKeys()"),
      SelectableText(
          exchangeMultisigKeysInfo ?? "exchangeMultisigKeysInfo is null"),
      LabeledTextInput(label: "Keys count", ctrl: exchangeMultisigKeysCount),
      CheckboxListTile(
          value: exchangeMultisigKeysForceUpdate,
          title: const Text("force_update_use_with_caution"),
          onChanged: (val) {
            setState(() {
              exchangeMultisigKeysForceUpdate = val == true;
            });
          }),
    ];

    for (var i = 0; i < exchangeMultisigKeysCtrls.length; i++) {
      ret.add(
        LabeledTextInput(
          label: "Multisig info #$i",
          ctrl: exchangeMultisigKeysCtrls[i],
        ),
      );
    }

    ret.add(LongOutlinedButton(
      text: "Wallet_exchangeMultisigKeys",
      onPressed: _exchangeMultisigKeysInit,
    ));
    return ret;
  }

  List<String> exportMultisigImagesText = [];

  void _exportMultisigImagesInit() {
    final imgs = monero.Wallet_exportMultisigImages(
      walletPtr!,
      info: [""],
      force_update_use_with_caution: false,
    );
    checkWalletError();
    setState(() {
      exportMultisigImagesText = imgs;
    });
  }

  List<Widget> _exportMultisigImages() {
    return [
      const Divider(),
      const SelectableText("Monero::Wallet::exportMultisigImages()"),
      ...exportMultisigImagesText.map((e) => SelectableText(e)),
      LongOutlinedButton(
        text: "exportMultisigImages",
        onPressed: _exportMultisigImagesInit,
      ),
    ];
  }

  void _importMultisigImagesInit() {
    final shoudBeCount = int.tryParse(importMultisigImagesCount.text);
    if (shoudBeCount == null) return;
    if (shoudBeCount != importMultisigImagesCtrls.length) {
      setState(() {
        importMultisigImagesCtrls = List.generate(
          shoudBeCount,
          (index) => TextEditingController(),
        );
      });
      return;
    }
    setState(() {
      importMultisigImagesInfo = monero.Wallet_importMultisigImages(
        walletPtr!,
        info: importMultisigImagesCtrls.map((e) => e.text).toList(),
      );
    });
    checkWalletError();
  }

  List<TextEditingController> importMultisigImagesCtrls = [];
  TextEditingController importMultisigImagesCount =
      TextEditingController(text: '1');
  TextEditingController importMultisigImagesThresholdCtrl =
      TextEditingController(text: '1');
  int? importMultisigImagesInfo;

  List<Widget> _importMultisigImages() {
    final ret = [
      const Divider(),
      const SelectableText("Monero::Wallet::importMultisigImages()"),
      SelectableText(importMultisigImagesInfo?.toString() ??
          "importMultisigImagesInfo is null"),
      LabeledTextInput(label: "Keys count", ctrl: importMultisigImagesCount),
    ];

    for (var i = 0; i < importMultisigImagesCtrls.length; i++) {
      ret.add(
        LabeledTextInput(
          label: "Multisig info #$i",
          ctrl: importMultisigImagesCtrls[i],
        ),
      );
    }

    ret.add(LongOutlinedButton(
      text: "Wallet_importMultisigImages",
      onPressed: _importMultisigImagesInit,
    ));
    return ret;
  }

  void checkWalletError({monero.wallet? wptr}) {
    final status = monero.Wallet_status(wptr ?? walletPtr!);
    if (status != 0) {
      final error = monero.Wallet_errorString(wptr ?? walletPtr!);
      Alert(
        title: "wallet2_api.h error!",
        body: [
          SelectableText(error),
        ],
        cancelable: true,
      ).show(context);
    }
  }
}
