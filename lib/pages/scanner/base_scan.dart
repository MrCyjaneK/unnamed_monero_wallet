import 'dart:convert';
import 'dart:io';

import 'package:anonero/pages/wallet/spend_confirm.dart';
import 'package:anonero/pages/wallet/spend_screen.dart';
import 'package:anonero/tools/dirs.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:bytewords/bytewords.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:monero/monero.dart';

class BaseScannerPage extends StatefulWidget {
  const BaseScannerPage({super.key});

  @override
  _BaseScannerPageState createState() => _BaseScannerPageState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const BaseScannerPage();
      },
    ));
  }
}

class _BaseScannerPageState extends State<BaseScannerPage> {
  List<String> urCodes = [];
  late var ur = URQRToURQRData(urCodes);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan"),
      ),
      body: Stack(
        children: [
          if (urCodes.isNotEmpty)
            LinearProgressIndicator(
              value: ur.progress,
            ),
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
        ],
      ),
    );
  }

  void _processUr() async {
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
      case "xmr-keyimage":
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
        Alert(title: "Key images imported", cancelable: true).show(context);
      case "xmr-txunsigned":
        final p = await getMoneroUnsignedTxPath();
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
        print(MONERO_UnsignedTransaction_amount(tx));
        // ignore: use_build_context_synchronously
        SpendConfirm.push(
          context,
          TxRequest(
            address: MONERO_UnsignedTransaction_recipientAddress(tx),
            amount:
                (num.parse(MONERO_UnsignedTransaction_amount(tx)) * 10e12) ~/ 1,
            notes: "N/A",
            isSweep: false,
            outputs: [],
            isUR: true,
            txPtr: tx,
          ),
        );
      case _:
        Alert(title: ur.data.toString(), cancelable: true).show(context);
    }
  }
}
