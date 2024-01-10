import 'dart:convert';

import 'package:anonero/tools/show_alert.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Map<String, dynamic> viewOnlyKeysLastScanned = {};

class ViewOnlyScannerPage extends StatefulWidget {
  const ViewOnlyScannerPage({super.key});

  @override
  State<ViewOnlyScannerPage> createState() => _ViewOnlyScannerPageState();

  static Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ViewOnlyScannerPage();
      },
    ));
  }
}

class _ViewOnlyScannerPageState extends State<ViewOnlyScannerPage> {
  bool popped = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan"),
      ),
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
                try {
                  viewOnlyKeysLastScanned = json.decode(barcode.rawValue!);
                  if (popped) return;
                  Navigator.of(context).pop();
                  setState(() {
                    popped = true;
                  });
                } catch (e) {
                  Alert(
                    title: e.toString(),
                    cancelable: true,
                  ).show(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
