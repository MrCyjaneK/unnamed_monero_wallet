import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:xmruw/const/app_name.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/node.dart';
import 'package:xmruw/tools/proxy.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monero/monero.dart';
import 'package:xmruw/tools/monero/subaddress_label.dart' as sl;
import 'package:mutex/mutex.dart';
import 'package:path/path.dart' as p;
import 'package:tor_binary/tor_binary_platform_interface.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

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

const notificationId = 777;

Future<void> showServiceNotification() async {
  if (!Platform.isAndroid) {
    print("showServiceNotification disabled - we are not on android.");
    return;
  }
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'anon_foreground',
    'Anon Foreground Notification',
    description: 'This channel is used for foreground notification.',
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('anon_mono'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final confOk = await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: false,
      autoStartOnBoot: false,
      isForegroundMode: false,

      notificationChannelId: 'anon_foreground',
      initialNotificationTitle: 'anon',
      initialNotificationContent: 'Loading wallet',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
    ),
  );
  if (!confOk) {
    debugPrint(
      "WARN: Failed to service.configure. Background mode will not work as expected",
    );
  }
  final startOk = await service.startService();
  if (!startOk) {
    debugPrint("WARN: failed to start service");
  }
}

final statsMx = Mutex();
Future<String> getStats() async {
  await statsMx.acquire();
  final ptrAddr =
      int.parse(File(await getWalletPointerAddrPath()).readAsStringSync());
  // return const JsonEncoder().convert(MONERO_isLibOk());
  final ptr = ffi.Pointer<ffi.Void>.fromAddress(ptrAddr);
  bool embeddedTor = await isSocks5ProxyListening("127.0.0.1", 42142);
  final height = MONERO_Wallet_daemonBlockChainHeight(ptr);
  final lh = MONERO_Wallet_blockChainHeight(ptr);
  final isBSync = MONERO_Wallet_isBackgroundSyncing(ptr) || isLockedMonero;
  final leftText = ((height - lh) <= 0) ? "" : "${height - lh} left ";
  statsMx.release();
  return "${((!embeddedTor) ? "" : "[Tor] ")}"
      "${(lh == height) ? "Synced: $lh " : "Syncing $leftText"}"
      "${(isBSync) ? "[BSYNC]" : ""}";
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    try {
      if (service is AndroidServiceInstance) {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          xmruw,
          await getStats(),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'anon_foreground',
              'Anon Foreground Notification',
              icon: 'anon_mono',
              ongoing: true,
              playSound: false,
              enableVibration: false,
              onlyAlertOnce: true,
              showWhen: false,
              importance: Importance.low,
              priority: Priority.low,
            ),
          ),
        );
      }
    } catch (e) {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      await service.stopSelf();
      return;
    }
  }
}
