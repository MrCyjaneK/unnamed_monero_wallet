import 'dart:io';

import 'package:bytewords/bytewords.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xmruw/helpers/platform_support.dart';
import 'package:xmruw/helpers/resource.g.dart';
import 'package:xmruw/pages/debug/urqr_codes.dart';
import 'package:xmruw/pages/scanner/base_scan.dart';
import 'package:xmruw/pages/wallet/wallet_home.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:xmruw/widgets/primary_label.dart';
import 'package:xmruw/widgets/urqr.dart';

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

enum OfflineMode {
  undefined,
  urqr,
  text,
}

class UrBroadcastPage extends StatefulWidget {
  const UrBroadcastPage({
    super.key,
    required this.filePath,
    required this.flag,
  });
  final UrBroadcastPageFlag flag;
  final String filePath;

  @override
  State<UrBroadcastPage> createState() => _UrBroadcastPageState();

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

class _UrBroadcastPageState extends State<UrBroadcastPage> {
  OfflineMode om = (canPlatformScan() && canPlatformText())
      ? OfflineMode.undefined
      : canPlatformScan()
          ? OfflineMode.urqr
          : OfflineMode.text;

  void _save() {
    CRFileSaver.saveFileWithDialog(
      SaveFileDialogParams(
        sourceFilePath: widget.filePath,
        destinationFileName: _urBroadcastPageFlagToFileName(widget.flag),
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
      body: switch (om) {
        OfflineMode.urqr => _buildUrQrPage(),
        OfflineMode.text => _buildTextPage(),
        OfflineMode.undefined => _pickPage(),
      },
      bottomNavigationBar: (om == OfflineMode.undefined)
          ? null
          : LongOutlinedButton(
              text: widget.flag == UrBroadcastPageFlag.xmrSignedTx
                  ? "FINISH"
                  : "CONTINUE",
              onPressed: () => _continue(context),
            ),
    );
  }

  Widget _buildUrQrPage() {
    return Column(
      children: [
        const SizedBox(height: 16),
        PrimaryLabel(
          title: _urBroadcastPageFlagToTitle(widget.flag),
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
                File(widget.filePath).readAsBytesSync(),
                _urBroadcastPageFlagToTag(widget.flag),
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
    );
  }

  Widget _pickPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                om = OfflineMode.urqr;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SvgPicture.asset(
                R.ASSETS_SCANNER_FRAME_SVG,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                om = OfflineMode.text;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.maxFinite,
                child: Center(
                  child: Text(
                    "Text",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextPage() {
    final fileContent = File(widget.filePath).readAsBytesSync();
    final bw = bytewordsEncode(BytewordsStyle.minimal, fileContent);
    final flag = _urBroadcastPageFlagToTag(widget.flag);
    final text = "$flag:$bw";
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SelectableText(text),
          ),
        ],
      ),
    );
  }

  void _continue(BuildContext c) async {
    if (widget.flag == UrBroadcastPageFlag.xmrSignedTx) {
      Navigator.of(c).pop();
      return;
    }
    BaseScannerPage.pushReplace(c);
  }
}
