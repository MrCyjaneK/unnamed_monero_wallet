import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Qr extends StatelessWidget {
  final String data;

  const Qr({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      backgroundColor: Colors.black,
      gapless: true,
      dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square, color: Colors.white),
      eyeStyle:
          const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.white),
      data: data,
      version: QrVersions.auto,
      //size: 280.0,
    );
  }
}
