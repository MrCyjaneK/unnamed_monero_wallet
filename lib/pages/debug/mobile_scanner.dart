import 'dart:typed_data';

import 'package:anonero/tools/show_alert.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerDebug extends StatelessWidget {
  const MobileScannerDebug({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner')),
      body: MobileScanner(
        fit: BoxFit.contain,
        controller: MobileScannerController(
          // facing: CameraFacing.back,
          // torchEnabled: false,
          returnImage: true,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
          if (image == null) return;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
            Alert(
              singleBody: Image(
                image: MemoryImage(image),
              ),
              callbackText: "${barcode.displayValue}",
              callback: () => Navigator.of(context).pop(),
            ).show(context);
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pop(context);
            });
          }
        },
      ),
    );
  }

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const MobileScannerDebug();
      },
    ));
  }
}
