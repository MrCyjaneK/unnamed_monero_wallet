import 'package:anonero/pages/pin_screen.dart';
import 'package:anonero/pages/setup/proxy_settings.dart';
import 'package:anonero/pages/wallet/settings/nodes_screen.dart';
import 'package:anonero/pages/wallet/settings/view_seed_page.dart';
import 'package:anonero/widgets/primary_label.dart';
import 'package:anonero/widgets/settings_list_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
          if (kDebugMode) const PrimaryLabel(title: "D38UG"),
        ],
      ),
    );
  }
}
