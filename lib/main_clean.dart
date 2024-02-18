
import 'package:flutter/services.dart';
import 'package:xmruw/const/resource.g.dart';
import 'package:xmruw/pages/anon/firstrun.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/node.dart';
import 'package:xmruw/tools/wallet_lock.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';
import 'package:xmruw/tools/wallet_manager.dart';

bool _walletExists = false;

void mainClean() async {
  WidgetsFlutterBinding.ensureInitialized();
  final wd = await getWd();
  if (!wd.existsSync()) wd.createSync();
  await loadConfig();
  await initLocalNodes();
  printStarts = config.printStarts;
  _walletExists =
      MONERO_WalletManager_walletExists(wmPtr, await getMainWalletPath());
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      showPerformanceOverlay: config.showPerformanceOverlay,
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
