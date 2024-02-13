import 'dart:io';

import 'package:xmruw/legacy.dart';
import 'package:xmruw/pages/debug.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/pages/setup/proxy_settings.dart';
import 'package:xmruw/pages/settings/nodes_screen.dart';
import 'package:xmruw/pages/settings/view_seed_page.dart';
import 'package:xmruw/tools/backup_class.dart' as b;
import 'package:xmruw/tools/can_backup.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/node.dart';
import 'package:xmruw/tools/proxy.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/primary_label.dart';
import 'package:xmruw/widgets/settings_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

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
  bool ok = MONERO_Wallet_setProxy(walletPtr!, address: "${p.address}:$port");
  print(ok);
  if (!ok) {
    // ignore: use_build_context_synchronously
    await Alert(title: MONERO_Wallet_errorString(walletPtr!), cancelable: true)
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const SettingsPage();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          const PrimaryLabel(title: "Connection"),
          const Divider(),
          SettingsListTile(
            title: "Nodes",
            subtitle: "Manage nodes",
            onClick: () => NodesScreen.push(context),
          ),
          SettingsListTile(
            title: "Proxy",
            subtitle: "Enabled",
            trailing: const Circle(
              color: Colors.green,
            ),
            onClick: () => ProxySettings.push(context),
          ),
          const Divider(),
          const PrimaryLabel(title: "Security"),
          const Divider(),
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
          const PrimaryLabel(title: "D38UG"),
          SettingsListTile(
            title: "Top secret menu",
            subtitle: "Click for free puppies 🐶🐶🐶",
            onClick: () => DebugPage.push(context),
          ),
        ],
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
            address: MONERO_Wallet_address(walletPtr!),
            seed: MONERO_Wallet_seed(walletPtr!, seedOffset: seedOffset),
            restoreHeight: MONERO_Wallet_getRefreshFromBlockHeight(walletPtr!),
            balanceAll: MONERO_Wallet_balance(walletPtr!, accountIndex: 0),
            numAccounts: MONERO_Wallet_numSubaddressAccounts(walletPtr!),
            numSubaddresses:
                MONERO_Wallet_numSubaddresses(walletPtr!, accountIndex: 0),
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
