import 'dart:io';

import 'package:anonero/pages/scanner/base_scan.dart';
import 'package:anonero/pages/wallet/wallet_home.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/primary_label.dart';
import 'package:anonero/widgets/urqr.dart';
import 'package:bytewords/bytewords.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:flutter/material.dart';

enum UrBroadcastPageFlag {
  xmrUnsignedTx,
  xmrOutputs,
  xmrKeyImage,
  xmrSignedTx,
}

String _urBroadcastPageFlagToTag(UrBroadcastPageFlag flag) {
  return switch (flag) {
    UrBroadcastPageFlag.xmrUnsignedTx => "xmr-txunsigned",
    UrBroadcastPageFlag.xmrSignedTx => "xmr-txsigned",
    UrBroadcastPageFlag.xmrOutputs => "xmr-output",
    UrBroadcastPageFlag.xmrKeyImage => "xmr-keyimage",
  };
}

String _urBroadcastPageFlagToTitle(UrBroadcastPageFlag flag) {
  return switch (flag) {
    UrBroadcastPageFlag.xmrUnsignedTx => "UNSIGNED TX",
    UrBroadcastPageFlag.xmrOutputs => "OUTPUTS",
    UrBroadcastPageFlag.xmrKeyImage => "KEY IMAGES",
    UrBroadcastPageFlag.xmrSignedTx => "SIGNED TX",
  };
}

String _urBroadcastPageFlagToFileName(UrBroadcastPageFlag flag) {
  return switch (flag) {
    UrBroadcastPageFlag.xmrUnsignedTx => "unsigned_transaction",
    UrBroadcastPageFlag.xmrOutputs => "export_outputs",
    UrBroadcastPageFlag.xmrKeyImage => "export_key_image",
    UrBroadcastPageFlag.xmrSignedTx => "signed_transaction",
  };
}

class UrBroadcastPage extends StatelessWidget {
  const UrBroadcastPage({
    super.key,
    required this.filePath,
    required this.flag,
  });
  final UrBroadcastPageFlag flag;
  final String filePath;

  void _save() {
    CRFileSaver.saveFileWithDialog(
      SaveFileDialogParams(
        sourceFilePath: filePath,
        destinationFileName: _urBroadcastPageFlagToFileName(flag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => WalletHome.push(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          PrimaryLabel(
            title: _urBroadcastPageFlagToTitle(flag),
            fontSize: 26,
            textAlign: TextAlign.center,
            enablePadding: false,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: URQR(
                frames: uint8ListToURQR(
                  File(filePath).readAsBytesSync(),
                  _urBroadcastPageFlagToTag(flag),
                  fragLength: 300,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.download),
            label: const Text("Save to file"),
          ),
          const Spacer(flex: 3),
        ],
      ),
      bottomNavigationBar: LongOutlinedButton(
        text: flag == UrBroadcastPageFlag.xmrSignedTx ? "FINISH" : "CONTINUE",
        onPressed: () => _continue(context),
      ),
    );
  }

  void _continue(BuildContext c) async {
    if (flag == UrBroadcastPageFlag.xmrSignedTx) {
      Navigator.of(c).pop();
      return;
    }
    BaseScannerPage.pushReplace(c);
  }

  static Future<void> push(BuildContext context,
      {required String filePath, required UrBroadcastPageFlag flag}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return UrBroadcastPage(filePath: filePath, flag: flag);
        },
      ),
    );
  }
}
