import 'dart:io';

import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/pages/sync_static_progress.dart';
import 'package:xmruw/tools/backup_class.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/format_monero.dart';
import 'package:xmruw/tools/node.dart' as n;
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key, required this.bd});

  final BackupDetails bd;

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();

  static void push(BuildContext context, BackupDetails bd) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return BackupRestorePage(bd: bd);
      },
    ));
  }
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backup Preview"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.6),
                      width: 1)),
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.all(4)),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Text("Wallet Details",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 15)),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                  ListTile(
                    title: Text("Primary Address",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        widget.bd.metadata?.backup?.wallet?.address ??
                            "unknown",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                  ListTile(
                    title: Text("Seed",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        widget.bd.metadata?.backup?.wallet?.seed ?? "",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                  ListTile(
                    title: Text("No of Sub-addresses",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        (widget.bd.metadata?.backup?.wallet?.numSubaddresses ??
                                0)
                            .toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: ListTile(
                          title: Text("Total Balance",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formatMonero(widget.bd.metadata?.backup?.wallet
                                      ?.balanceAll ??
                                  0),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: ListTile(
                          title: Text("Restore Height",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              (widget.bd.metadata?.backup?.wallet
                                          ?.restoreHeight ??
                                      0)
                                  .toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.all(6))
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.6),
                      width: 1)),
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.all(4)),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Text("Node Details",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 15)),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                  ListTile(
                    title: Text("Node Address",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "${widget.bd.metadata?.backup?.node?.host}:${widget.bd.metadata?.backup?.node?.rpcPort}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(6))
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          LongOutlinedButton(text: "RESTORE", onPressed: _restore),
    );
  }

  void _restore() async {
    await SyncStaticProgress.push(context, "RESTORING WALLET", () async {
      await n.NodeStore.saveNode(
        n.Node(
            address: widget.bd.metadata?.backup?.node?.host ?? "",
            username: widget.bd.metadata?.backup?.node?.username ?? "",
            password: widget.bd.metadata?.backup?.node?.password ?? "",
            id: n.NodeStore.getUniqueId()),
        current: true,
      );
      File(await getMainWalletPath()).writeAsBytes(widget.bd.walletData!);
      File("${await getMainWalletPath()}.keys")
          .writeAsBytes(widget.bd.walletKeysData!);
    });
    // ignore: use_build_context_synchronously
    PinScreen.pushReplace(
      context,
      PinScreenFlag.openMainWallet,
      passphrase: "",
    );
  }
}
