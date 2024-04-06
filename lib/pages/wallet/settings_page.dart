import 'dart:io';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/legacy.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/debug.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/pages/settings/about.dart';
import 'package:xmruw/pages/settings/currency_settings.dart';
import 'package:xmruw/pages/settings/nodes_screen.dart';
import 'package:xmruw/pages/settings/theme_settings.dart';
import 'package:xmruw/pages/settings/view_seed_page.dart';
import 'package:xmruw/pages/setup/proxy_settings.dart';
import 'package:xmruw/pages/wallet/configuration_page.dart';
import 'package:xmruw/tools/backup_class.dart' as b;
import 'package:xmruw/tools/can_backup.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/is_offline.dart';
import 'package:xmruw/tools/monero/account_index.dart';
import 'package:xmruw/tools/node.dart';
import 'package:xmruw/tools/proxy.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/primary_label.dart';
import 'package:xmruw/widgets/settings_list_tile.dart';
import 'package:xmruw/widgets/setup_logo.dart';

bool isProxyOn = false;

Future<void> setProxy(BuildContext c) async {
  if (proc != null) return;
  final p = await ProxyStore.getProxy();
  final node = await NodeStore.getCurrentNode();
  if (node == null) {
    isProxyOn = false;
    return;
  }
  final port = node.address.contains(".b32.i2p") ? p.i2pPort : p.torPort;
  bool ok = monero.Wallet_setProxy(walletPtr!, address: "${p.address}:$port");
  print(ok);
  if (!ok) {
    // ignore: use_build_context_synchronously
    await Alert(title: monero.Wallet_errorString(walletPtr!), cancelable: true)
        .show(c);
    isProxyOn = false;
    return;
  }
  isProxyOn = true;
}

Future<void> setNode(BuildContext c) async {
  final node = await NodeStore.getCurrentNode();
  if (node == null) {
    return;
  }
  // ignore: use_build_context_synchronously
  return Alert(
          title: "Node set, you need to restart your wallet.", cancelable: true)
      .show(c);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const SettingsPage();
      },
    ));
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool localIfOffline = isOffline;
  @override
  void initState() {
    isOfflineRefresh().then((_) {
      setState(() {
        localIfOffline = isOffline;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SetupLogo(title: "Settings"),
            const Divider(),
            const PrimaryLabel(title: "Connection"),
            SettingsListTile(
              title: "Nodes",
              subtitle: "Manage nodes",
              onClick: localIfOffline ? null : () => NodesScreen.push(context),
            ),
            SettingsListTile(
              title: "Proxy",
              subtitle: (proc != null)
                  ? 'status: embedded tor running'
                  : 'status: unknown',
              trailing: Circle(
                color: (proc != null) ? Colors.green : Colors.yellow,
              ),
              onClick:
                  localIfOffline ? null : () => ProxySettings.push(context),
            ),
            const PrimaryLabel(title: "Look and feel"),
            SettingsListTile(
              title: "Theme",
              subtitle: "Change app theme",
              onClick: () => ThemeSettingsPage.push(context),
            ),
            SettingsListTile(
              title: "Currency",
              subtitle: "Change fiat currency",
              onClick: () => CurrencySettingsPage.push(context),
            ),
            const PrimaryLabel(title: "Security"),
            const SettingsListTile(
              title: "Change Pin",
            ),
            SettingsListTile(
              title: "View Seed",
              onClick: () => _viewSeed(context),
            ),
            SettingsListTile(
              title: "Export Backup",
              onClick: !canBackup() ? null : () => _exportBackup(context),
            ),
            const SettingsListTile(
              title: "Secure Wipe",
            ),
            const PrimaryLabel(title: "Advanced"),
            SettingsListTile(
              title: "Configuration",
              subtitle: "Change app behaviour, enable experimental features",
              onClick: () => ConfigurationPage.push(context),
            ),
            if (config.enableExperiments)
              SettingsListTile(
                title: "Experiments",
                subtitle: "Do fancy stuff",
                onClick: () => DebugPage.push(context),
              ),
            const PrimaryLabel(title: "About"),
            SettingsListTile(
              title: "About the app",
              subtitle: "Licenses and other fancy stuff",
              onClick: () => AboutPage.push(context),
            ),
          ],
        ),
      ),
    );
  }

  void _exportBackup(BuildContext c) async {
    final tCtrl = TextEditingController();
    await Alert(
      body: [
        LabeledTextInput(label: "Seed offset", ctrl: tCtrl),
      ],
      callback: () => Navigator.of(c).pop(),
    ).show(c);
    final seedOffset = tCtrl.text;
    if (tCtrl.text == "") {
      return;
    }
    final mwp = await getMainWalletPath();
    final node = await NodeStore.getCurrentNode();

    final b.BackupDetails bd = b.BackupDetails(
      walletData: File(mwp).readAsBytesSync(),
      walletKeysData: File("$mwp.keys").readAsBytesSync(),
      metadata: b.AnonJSON(
        version: "1.0",
        backup: b.Backup(
          node: b.Node(
            host: node?.address.split(":")[0],
            username: node?.username,
            password: node?.password,
            rpcPort: int.tryParse(node?.address.split(":")[1] ?? "?Sdatf"),
            isOnion: true,
            networkType: "NetworkType_Mainnet",
          ),
          wallet: b.Wallet(
            address: monero.Wallet_address(walletPtr!),
            seed: monero.Wallet_seed(walletPtr!, seedOffset: seedOffset),
            restoreHeight: monero.Wallet_getRefreshFromBlockHeight(walletPtr!),
            balanceAll: monero.Wallet_balance(walletPtr!,
                accountIndex: globalAccountIndex),
            numAccounts: monero.Wallet_numSubaddressAccounts(walletPtr!),
            numSubaddresses: monero.Wallet_numSubaddresses(walletPtr!,
                accountIndex: globalAccountIndex),
            isWatchOnly: false, // v1 doesn't care. We can work both ways.
            isSynchronized: false, // this file was literally kept offline?
          ),
          meta: b.Meta(
            network: "NetworkType_Mainnet",
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 200));
    // ignore: use_build_context_synchronously
    await bd.encrypt(c, seedOffset);
  }

  void _viewSeed(BuildContext c) async {
    final tCtrl = TextEditingController();
    await Alert(
      body: [
        LabeledTextInput(label: "Seed offset", ctrl: tCtrl),
      ],
      callback: () => Navigator.of(c).pop(),
    ).show(c);
    // ignore: use_build_context_synchronously
    ViewSeedPage.push(c, seedOffset: tCtrl.text);
  }
}
