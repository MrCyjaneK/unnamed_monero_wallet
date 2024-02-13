import 'dart:convert';
import 'dart:io';

import 'package:xmruw/const/resource.g.dart';
import 'package:xmruw/legacy.dart';
import 'package:xmruw/pages/sync_static_progress.dart';
import 'package:xmruw/pages/wallet/spend_confirm.dart';
import 'package:xmruw/pages/wallet/spend_screen.dart';
import 'package:xmruw/pages/wallet/spend_success.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/hexdump.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/primary_label.dart';
import 'package:xmruw/widgets/transaction_list/popup_menu.dart';
import 'package:bytewords/bytewords.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:monero/monero.dart';

class BaseScannerPage extends StatefulWidget {
  const BaseScannerPage({super.key});

  @override
  _BaseScannerPageState createState() => _BaseScannerPageState();

  static Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const BaseScannerPage();
      },
    ));
  }

  static void pushReplace(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const BaseScannerPage();
      },
    ));
  }
}

class _BaseScannerPageState extends State<BaseScannerPage> {
  List<String> urCodes = [];
  late var ur = URQRToURQRData(urCodes);

  Widget _debug() {
    return SingleChildScrollView(
      child: SelectableText(
        "${const JsonEncoder.withIndent('    ').convert(ur.toJson())}\n\n${_urParts()}",
        style: const TextStyle(fontSize: 8),
      ),
    );
  }

  List<int> _urParts() {
    List<int> l = [];
    for (var inp in ur.inputs) {
      try {
        l.add(int.parse(inp.split("/")[1].split("-")[0]));
      } catch (e) {}
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.contain,
            controller: MobileScannerController(
              // facing: CameraFacing.back,
              // torchEnabled: false,
              returnImage: false,
            ),
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                print(barcode.rawValue!);
                // check if address
                if (MONERO_Wallet_addressValid(barcode.rawValue!, 0)) {
                  Navigator.of(context).pop();
                  SpendScreen.push(context, address: barcode.rawValue!);
                } else if (barcode.rawValue!.startsWith("ur:")) {
                  if (urCodes.contains(barcode.rawValue)) return;
                  setState(() {
                    urCodes.add(barcode.rawValue!);
                    ur = URQRToURQRData(urCodes);
                  });
                  if (ur.progress == 1) _processUr();
                }
              }
            },
          ),
          Center(
            child: PrimaryLabel(
              title:
                  "${_urParts().length.toString().padLeft(ur.count.toString().length, "0")}/${ur.count}",
              textAlign: TextAlign.center,
              enablePadding: false,
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            margin: const EdgeInsets.all(68),
            child: SvgPicture.asset(
              R.ASSETS_SCANNER_FRAME_SVG,
              color: Colors.white24, // what. what am I supposed to use.
            ),
          ),
          SizedBox(
            child: Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(
                  painter: ProgressPainter(
                    urQrProgress: URQrProgress(
                      expectedPartCount: ur.count - 1,
                      processedPartsCount: ur.inputs.length,
                      receivedPartIndexes: _urParts(),
                      percentage: ur.progress,
                    ),
                  ),
                ),
              ),
            ),
          ),
          //_debug(),
        ],
      ),
    );
  }

  bool isProcessing = false;

  void _processUr() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
    });
    print(const JsonEncoder.withIndent('    ').convert(ur));
    switch (ur.tag) {
      case "debug":
        Alert(title: utf8.decode(ur.data), cancelable: true).show(context);
      case "xmr-output":
        final p = await getMoneroImportOutputsPath();
        File(p).writeAsBytesSync(ur.data);
        final ok = MONERO_Wallet_importOutputs(walletPtr!, p);
        if (!ok) {
          // ignore: use_build_context_synchronously
          await Alert(
            title: MONERO_Wallet_errorString(walletPtr!),
            cancelable: true,
          ).show(context);
          return;
        }
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        exportKeyImages(context);
      case "xmr-keyimage":
        SyncStaticProgress.push(context, "IMPORTING KEY IMAGES", () async {
          await Future.delayed(const Duration(milliseconds: 100));
          final p = await getMoneroImportKeyImagesPath();
          File(p).writeAsBytesSync(ur.data);
          final preState = MONERO_Wallet_trustedDaemon(walletPtr!);
          MONERO_Wallet_setTrustedDaemon(walletPtr!, arg: true);
          final ok = MONERO_Wallet_importKeyImages(walletPtr!, p);
          if (!ok) {
            // ignore: use_build_context_synchronously
            Alert(
              title: MONERO_Wallet_errorString(walletPtr!),
              cancelable: true,
            ).show(context);
            MONERO_Wallet_setTrustedDaemon(walletPtr!, arg: preState);
            return;
          }
          MONERO_Wallet_setTrustedDaemon(walletPtr!, arg: preState);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        });
      case "xmr-txunsigned":
        final p = await getMoneroUnsignedTxPath();
        if (File(p).existsSync()) File(p).deleteSync();
        File(p).writeAsBytesSync(ur.data);
        final MONERO_UnsignedTransaction tx =
            MONERO_Wallet_loadUnsignedTx(walletPtr!, unsigned_filename: p);
        if (MONERO_UnsignedTransaction_status(tx) != 0) {
          // ignore: use_build_context_synchronously
          await Alert(
            title: MONERO_UnsignedTransaction_errorString(tx),
            cancelable: true,
          ).show(context);
          return;
        }
        // ignore: use_build_context_synchronously
        SpendConfirm.pushReplace(
          context,
          TxRequest(
            address: MONERO_UnsignedTransaction_recipientAddress(tx),
            amount: (num.parse(MONERO_UnsignedTransaction_amount(tx))) ~/ 1,
            fee: (num.parse(MONERO_UnsignedTransaction_fee(tx))) ~/ 1,
            notes: "N/A",
            isSweep: false,
            outputs: [],
            isUR: true,
            txPtr: tx,
          ),
        );
      case "xmr-txsigned":
        final p = await getMoneroSignedTxPath();
        File(p).writeAsBytesSync(ur.data);
        final tx = MONERO_Wallet_submitTransaction(walletPtr!, p);
        if (tx == false) {
          // ignore: use_build_context_synchronously
          await Alert(
            title: MONERO_Wallet_errorString(walletPtr!),
            cancelable: true,
          ).show(context);
          return;
        }
        // ignore: use_build_context_synchronously
        SpendSuccess.push(context);

      case _:
        Alert(
          singleBody: SelectableText(
            hexDump(ur.data),
            style: const TextStyle(fontSize: 8),
          ),
          cancelable: true,
        ).show(context);
    }
  }
}
