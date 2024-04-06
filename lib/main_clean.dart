import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/helpers/resource.g.dart';
import 'package:xmruw/pages/anon/firstrun.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/config/themes.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/node.dart';
import 'package:xmruw/tools/wallet_lock.dart';
import 'package:xmruw/tools/wallet_manager.dart';

bool _walletExists = false;

void mainClean() async {
  WidgetsFlutterBinding.ensureInitialized();
  final wd = await getWd();
  if (!wd.existsSync()) wd.createSync();
  await loadConfig();

  monero.printStarts = config.printStarts;
  _walletExists =
      monero.WalletManager_walletExists(wmPtr, await getMainWalletPath());
  runApp(
    Listener(
      onPointerDown: (_) => _uh(),
      child: const MyApp(),
    ),
  );
}

Future<void> initLocalNodes() async {
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

Future<void> loadConfig() async {
  config = Config.load(await getConfigFile());
}

void _uh() {
  lastClick = DateTime.now();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  var themeData = getTheme(config.theme);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      showPerformanceOverlay: config.showPerformanceOverlay,
      title: 'xmruw',
      theme: themeData,
      scrollBehavior: MyCustomScrollBehavior(),
      home: _walletExists
          ? const PinScreen(
              flag: PinScreenFlag.openMainWallet,
            )
          : const AnonFirstRun(),
    );
  }

  static void setTheme(BuildContext context, ThemeData theme) {
    MyAppState state = context.findAncestorStateOfType<MyAppState>()!;
    state.setState(() {
      state.themeData = theme;
    });
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
