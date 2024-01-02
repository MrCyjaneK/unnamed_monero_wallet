import 'package:anonero/pages/debug.dart';
import 'package:anonero/pages/pin_screen.dart';
import 'package:anonero/pages/setup/proxy_settings.dart';
import 'package:anonero/pages/settings/nodes_screen.dart';
import 'package:anonero/pages/settings/view_seed_page.dart';
import 'package:anonero/tools/node.dart';
import 'package:anonero/tools/proxy.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/primary_label.dart';
import 'package:anonero/widgets/settings_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

bool isProxyOn = false;

Future<void> setProxy(BuildContext c) async {
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
            subtitle: "Disabled",
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
            onClick: () => ViewSeedPage.push(context),
          ),
          const SettingsListTile(
            title: "Export Backup",
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
}
