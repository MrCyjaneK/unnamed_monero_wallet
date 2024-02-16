import 'dart:io';

import 'package:flutter/services.dart';
import 'package:xmruw/const/resource.g.dart';
import 'package:xmruw/pages/anon/firstrun.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/fuck_firebase.dart';
import 'package:xmruw/tools/load_perf_data.dart';
import 'package:xmruw/tools/node.dart';
import 'package:xmruw/tools/wallet_lock.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';
import 'package:xmruw/tools/wallet_manager.dart';

bool _walletExists = false;
bool showPerformanceOverlay = false;
bool disableProxy = false;

void main_clean() async {
  WidgetsFlutterBinding.ensureInitialized();
  final wd = await getWd();
  if (!wd.existsSync()) wd.createSync();
  await loadPerfData();
  initLocalNodes();
  // printStarts = true;
  _walletExists =
      MONERO_WalletManager_walletExists(wmPtr, await getMainWalletPath());
  disableProxy = File(await getDisableProxyFlagFile()).existsSync();
  showPerformanceOverlay =
      File(await getShowPerformanceOverlayFlagFile()).existsSync();
  runApp(
    Listener(
      onPointerDown: (_) => _uh(),
      child: const MyApp(),
    ),
  );
}

void initLocalNodes() async {
  final nodes = await NodeStore.getNodes();
  if (nodes.nodes.isNotEmpty) return;

  final nListStr = await rootBundle.loadString(R.ASSETS_NODES_TXT);
  final nList = nListStr.split("\n");
  nList.shuffle();
  for (var node in nList) {
    node = node.trim();
    if (Uri.tryParse(node) == null) continue;
    await NodeStore.saveNode(
      Node(
          address: node,
          username: '',
          password: '',
          id: NodeStore.getUniqueId()),
      current: true,
    );
  }
}

void _uh() {
  lastClick = DateTime.now();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      showPerformanceOverlay: showPerformanceOverlay,
      title: 'xmruw',
      theme: ThemeData(
        fontFamily: 'RobotoMono',
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.cyan, brightness: Brightness.dark),
        dividerTheme: const DividerThemeData(
          thickness: 3,
        ),
        useMaterial3: true,
      ),
      home: _walletExists
          ? const PinScreen(
              flag: PinScreenFlag.openMainWallet,
            )
          : const AnonFirstRun(),
    );
  }
}
