import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:mutex/mutex.dart';
import 'package:path/path.dart' as p;
import 'package:tor_binary/tor_binary_platform_interface.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/monero/account_index.dart';
import 'package:xmruw/tools/monero/subaddress_label.dart' as sl;
import 'package:xmruw/tools/node.dart';
import 'package:xmruw/tools/proxy.dart';
import 'package:xmruw/tools/wallet_ptr.dart';

class Transaction {
  final String displayLabel;
  String subaddressLabel = sl.subaddressLabel(0); // TODO: fixme
  late final String address = monero.Wallet_address(
    walletPtr!,
    accountIndex: globalAccountIndex,
    addressIndex: 0,
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
  late final bool isConfirmed = !isPending;
  final String hash;

  Map<String, dynamic> toJson() {
    return {
      "displayLabel": displayLabel,
      "subaddressLabel": subaddressLabel,
      "address": address,
      "description": description,
      "fee": fee,
      "confirmations": confirmations,
      "isPending": isPending,
      "blockheight": blockheight,
      "accountIndex": accountIndex,
      "paymentId": paymentId,
      "amount": amount,
      "isSpend": isSpend,
      "timeStamp": timeStamp.toIso8601String(),
      "isConfirmed": isConfirmed,
      "hash": hash,
    };
  }

  // S finalubAddress? subAddress;
  // List<Transfer> transfers = [];
  // final int txIndex;
  final monero.TransactionInfo txInfo;
  Transaction({
    required this.txInfo,
  })  : displayLabel = monero.TransactionInfo_label(txInfo),
        hash = monero.TransactionInfo_hash(txInfo),
        timeStamp = DateTime.fromMillisecondsSinceEpoch(
          monero.TransactionInfo_timestamp(txInfo) * 1000,
        ),
        isSpend = monero.TransactionInfo_direction(txInfo) ==
            monero.TransactionInfo_Direction.Out,
        amount = monero.TransactionInfo_amount(txInfo),
        paymentId = monero.TransactionInfo_paymentId(txInfo),
        accountIndex = monero.TransactionInfo_subaddrAccount(txInfo),
        blockheight = monero.TransactionInfo_blockHeight(txInfo),
        confirmations = monero.TransactionInfo_confirmations(txInfo),
        fee = monero.TransactionInfo_fee(txInfo),
        description = monero.TransactionInfo_description(txInfo);
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

Process? proc;

Future<void> runEmbeddedTor() async {
  if (!Platform.isAndroid) {
    print("Not starting embedded Tor - we are not on android");
    return;
  }

  final docs = await getWd();
  const port = 42142;

  final node = await NodeStore.getCurrentNode();
  if ((node?.address.contains('.i2p:') == true) || node == null) {
    print("We are connected to i2p (or not at all), ignoring tor config.");
    return;
  }
  if (!config.routeClearnetThruTor &&
      node.address.contains('.onion') == false) {
    print("!config.routeClearnetThruTor and we are not .onioning");
    return;
  }

  if (config.disableProxy) {
    print("disableProxy flag found, not starting tor");
    return;
  }
  // final torBinPath = p.join(
  //     await BackUpRestoreChannel().getAndroidNativeLibraryDirectory(),
  //     "libKmpTor.so");
  final torBinPath =
      p.join((await TorBinaryPlatform.instance.getBinaryPath())!, "libtor.so");
  print("torPath: $torBinPath");
  final proxy = await ProxyStore.getProxy();
  final isProxyRunning = await isSocks5ProxyListening(
      proxy.getAddress(NodeNetwork.onion), proxy.torPort);

  if (isProxyRunning) {
    print("Proxy is running");
    return;
  }

  print("Starting embedded tor");
  print("app docs: $docs");
  final torrc = """
SocksPort $port
Log notice file ${p.join(docs.absolute.path, "tor.log")}
RunAsDaemon 0
DataDirectory ${p.join(docs.absolute.path, "tor-data")}
""";
  final torrcPath = p.join(docs.absolute.path, "torrc");
  File(torrcPath).writeAsStringSync(torrc);

  if (proc != null) {
    proc?.kill();
    await Future.delayed(const Duration(seconds: 1));
    proc?.kill(ProcessSignal.sigkill);
    await Future.delayed(const Duration(seconds: 1));
    final td = Directory(p.join(docs.absolute.path, "tor-data"));
    if (td.existsSync()) {
      td.deleteSync(recursive: true);
    }
    proc?.kill(ProcessSignal.sigkill);
    await Future.delayed(const Duration(seconds: 1));
  }
  proc = await Process.start(torBinPath, ["-f", torrcPath]);
  proc?.stdout.transform(utf8.decoder).forEach(print);
  proc?.stderr.transform(utf8.decoder).forEach(print);
}

Future<bool> isSocks5ProxyListening(String host, int port) async {
  try {
    final socket = await Socket.connect(host, port);
    socket.destroy();
    return true;
  } catch (e) {
    return false;
  }
}
