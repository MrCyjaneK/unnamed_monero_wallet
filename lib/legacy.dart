import 'dart:math';

import 'package:anonero/tools/wallet_ptr.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';
import 'package:anonero/tools/monero/subaddress_label.dart' as sl;

const ColorScheme colorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xffFF6600),
  onPrimary: Color(0xff000000),
  primaryContainer: Color(0xff297ea0),
  onPrimaryContainer: Color(0xffd9edf5),
  secondary: Color(0xffa1e9df),
  onSecondary: Color(0xff030303),
  secondaryContainer: Color(0xff005049),
  onSecondaryContainer: Color(0xffd0e3e1),
  tertiary: Color(0xffa0e5e5),
  onTertiary: Color(0xff181e1e),
  tertiaryContainer: Color(0xff004f50),
  onTertiaryContainer: Color(0xffd0e2e3),
  error: Color(0xffcf6679),
  onError: Color(0xff1e1214),
  errorContainer: Color(0xffb1384e),
  onErrorContainer: Color(0xfff9dde2),
  outline: Color(0xff959999),
  background: Color(0xff000000),
  onBackground: Color(0xffe3e4e4),
  surface: Color(0xff131516),
  onSurface: Color(0xfff1f1f1),
  surfaceVariant: Color(0xff15191b),
  onSurfaceVariant: Color(0xffe3e3e4),
  inverseSurface: Color(0xfffafcfd),
  onInverseSurface: Color(0xff0e0e0e),
  inversePrimary: Color(0xff355967),
  shadow: Color(0xff000000),
);

class Transaction {
  late final String displayLabel = MONERO_TransactionInfo_label(txInfo);
  late String subaddressLabel = sl.subaddressLabel(accountIndex);
  late final String address = MONERO_Wallet_address(
    walletPtr!,
    accountIndex: 0,
    addressIndex: accountIndex,
  );
  final String description;
  final int fee;
  final int confirmations;
  late final bool isPending = confirmations < maxConfirms;
  final int blockheight;
  final int accountIndex;
  final String paymentId;
  final int amount;
  final bool isSpend;
  late DateTime timeStamp;
  // late int addressIndex = MONERO_TransactionInfo_subaddrAccount(_tx);
  late final bool isConfirmed = !isPending;
  final String hash;
  // S finalubAddress? subAddress;
  // List<Transfer> transfers = [];
  // final int txIndex;
  final MONERO_TransactionInfo txInfo;
  Transaction({
    required this.txInfo,
  })  : hash = MONERO_TransactionInfo_hash(txInfo),
        timeStamp = DateTime.fromMillisecondsSinceEpoch(
          MONERO_TransactionInfo_timestamp(txInfo) * 1000,
        ),
        isSpend = MONERO_TransactionInfo_direction(txInfo) ==
            TransactionInfo_Direction.Out,
        amount = MONERO_TransactionInfo_amount(txInfo),
        paymentId = MONERO_TransactionInfo_paymentId(txInfo),
        accountIndex = MONERO_TransactionInfo_subaddrAccount(txInfo),
        blockheight = MONERO_TransactionInfo_blockHeight(txInfo),
        confirmations = MONERO_TransactionInfo_confirmations(txInfo),
        fee = MONERO_TransactionInfo_fee(txInfo),
        description = MONERO_TransactionInfo_description(txInfo);
}

class SubAddress {
  int? accountIndex;
  String? address;
  String? squashedAddress;
  int? addressIndex;
  num? totalAmount;
  String? label;
  String? displayLabel;

  SubAddress(
      {this.accountIndex,
      this.address,
      this.squashedAddress,
      this.addressIndex,
      this.label});
}

class Transfer {
  num? amount;
  String? address;
}

const maxConfirms = 10;

class ProgressPainter extends CustomPainter {
  final URQrProgress urQrProgress;

  ProgressPainter({required this.urQrProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width * 0.9;
    final rect = Rect.fromCenter(center: c, width: radius, height: radius);
    const fullAngle = 360.0;
    var startAngle = 0.0;
    for (int i = 0; i < urQrProgress.expectedPartCount.toInt(); i++) {
      var sweepAngle =
          (1 / urQrProgress.expectedPartCount) * fullAngle * pi / 180.0;
      drawSector(canvas, urQrProgress.receivedPartIndexes.contains(i), rect,
          startAngle, sweepAngle);
      startAngle += sweepAngle;
    }
  }

  void drawSector(Canvas canvas, bool isActive, Rect rect, double startAngle,
      double sweepAngle) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = isActive ? const Color(0xffff6600) : Colors.white70;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant ProgressPainter oldDelegate) {
    return urQrProgress != oldDelegate.urQrProgress;
  }
}

class URQrProgress {
  int expectedPartCount;
  int processedPartsCount;
  List<int> receivedPartIndexes;
  double percentage;

  URQrProgress({
    required this.expectedPartCount,
    required this.processedPartsCount,
    required this.receivedPartIndexes,
    required this.percentage,
  });

  bool equals(URQrProgress? progress) {
    if (progress == null) {
      return false;
    }
    return processedPartsCount == progress.processedPartsCount;
  }
}
