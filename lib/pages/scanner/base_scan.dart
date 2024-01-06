import 'package:anonero/pages/wallet/spend_screen.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan"),
      ),
      body: MobileScanner(
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
            // check if tx
            if (MONERO_Wallet_addressValid(barcode.rawValue!, 0)) {
              Navigator.of(context).pop();
              SpendScreen.push(context, address: barcode.rawValue!);
            }
          }
        },
      ),
    );
  }
}
