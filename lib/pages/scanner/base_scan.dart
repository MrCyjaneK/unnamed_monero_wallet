import 'dart:convert';

import 'package:xmruw/helpers/resource.g.dart';
import 'package:xmruw/legacy.dart';
import 'package:xmruw/pages/scanner/process_ur.dart';
import 'package:xmruw/pages/wallet/spend_screen.dart';
import 'package:xmruw/widgets/primary_label.dart';
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

    await processUr(context, ur.tag, ur.data);
    setState(() {
      isProcessing = false;
    });
  }
}
