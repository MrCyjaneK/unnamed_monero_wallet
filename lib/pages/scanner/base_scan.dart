import 'dart:convert';
import 'dart:typed_data';

import 'package:bytewords/bytewords.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/helpers/resource.g.dart';
import 'package:xmruw/legacy.dart';
import 'package:xmruw/pages/scanner/process_ur.dart';
import 'package:xmruw/pages/wallet/spend_screen.dart';
import 'package:xmruw/widgets/primary_label.dart';

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
                if (monero.Wallet_addressValid(barcode.rawValue!, 0)) {
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

class URQRData {
  URQRData(
      {required this.tag,
      required this.data,
      required this.str,
      required this.progress,
      required this.count,
      required this.error,
      required this.inputs});
  final String tag;
  final Uint8List data;
  final String str;
  final double progress;
  final int count;
  final String error;
  final List<String> inputs;
  Map<String, dynamic> toJson() {
    return {
      "tag": tag,
      "str": str,
      "data": data,
      "progress": progress,
      "count": count,
      "error": error,
      "inputs": inputs,
    };
  }
}

URQRData URQRToURQRData(List<String> urqr_) {
  final urqr = urqr_.toSet().toList();
  urqr.sort((s1, s2) {
    final s1s = s1.split("/");
    final s1frameStr = s1s[1].split("-");
    final s1curFrame = int.parse(s1frameStr[0]);
    final s2s = s2.split("/");
    final s2frameStr = s2s[1].split("-");
    final s2curFrame = int.parse(s2frameStr[0]);
    return s1curFrame - s2curFrame;
  });

  String tag = '';
  int count = 0;
  String bw = '';
  for (var elm in urqr) {
    final s = elm.substring(elm.indexOf(":") + 1); // strip down ur: prefix
    final s2 = s.split("/");
    tag = s2[0];
    final frameStr = s2[1].split("-");
    // final curFrame = int.parse(frameStr[0]);
    count = int.parse(frameStr[1]);
    final byteWords = s2[2];
    bw += byteWords;
  }
  Uint8List? data;
  String? error;
  if ((urqr.length / count) == 1) {
    try {
      data = bytewordsDecode(BytewordsStyle.minimal, bw);
    } catch (e) {
      error = e.toString();
    }
  }
  return URQRData(
    tag: tag,
    str: bw,
    data: data ?? Uint8List.fromList([]),
    progress: count == 0 ? 0 : (urqr.length / count),
    count: count,
    error: error ?? "",
    inputs: urqr,
  );
}
