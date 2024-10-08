import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/advanced_expansion_tile.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';

final _rescanBlockchainSyncInfo = """
NOTE: (sync) waits for the entire blockchain to be synced, therefore it may
take significant amount of time to complete. During that time wallet will be
unresponsive, you will however observe intense network usage."""
    .split("\n")
    .join(" ");

class MoneroDartAdvancedDebug extends StatefulWidget {
  const MoneroDartAdvancedDebug({super.key});

  @override
  State<MoneroDartAdvancedDebug> createState() =>
      _MoneroDartAdvancedDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const MoneroDartAdvancedDebug();
      },
    ));
  }
}

class _MoneroDartAdvancedDebugState extends State<MoneroDartAdvancedDebug> {
  void _rescanBlockchain() {
    final rsc = monero.Wallet_rescanBlockchain(walletPtr!);
    Alert(
            title: "result: $rsc\n"
                "status: ${monero.Wallet_status(walletPtr!)}\n"
                "errorString: ${monero.Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  void _rescanBlockchainAsync() {
    monero.Wallet_rescanBlockchainAsync(walletPtr!);
    Alert(
            title: "result: void\n"
                "status: ${monero.Wallet_status(walletPtr!)}\n"
                "errorString: ${monero.Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  void _refresh() {
    final rsc = monero.Wallet_refresh(walletPtr!);
    Alert(
            title: "result: $rsc\n"
                "status: ${monero.Wallet_status(walletPtr!)}\n"
                "errorString: ${monero.Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  void _store() {
    final rsc = monero.Wallet_store(walletPtr!);
    Alert(
            title: "result: $rsc\n"
                "status: ${monero.Wallet_status(walletPtr!)}\n"
                "errorString: ${monero.Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  void _connectToDaemon() {
    final rsc = monero.Wallet_connectToDaemon(walletPtr!);
    Alert(
            title: "result: $rsc\n"
                "status: ${monero.Wallet_status(walletPtr!)}\n"
                "errorString: ${monero.Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  void _refreshAsync() {
    monero.Wallet_refreshAsync(walletPtr!);
    Alert(
            title: "result: void\n"
                "status: ${monero.Wallet_status(walletPtr!)}\n"
                "errorString: ${monero.Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("monero.dart advanced"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AET(
              "Rescan Blockchain",
              [
                SelectableText(_rescanBlockchainSyncInfo),
                LongOutlinedButton(
                  text: "Rescan Blockchain (sync)",
                  onPressed: _rescanBlockchain,
                ),
                LongOutlinedButton(
                  text: "Rescan Blockchain (async)",
                  onPressed: _rescanBlockchainAsync,
                ),
              ],
            ),
            AET(
              "Refresh",
              [
                LongOutlinedButton(
                  text: "Refresh (sync)",
                  onPressed: _refresh,
                ),
                LongOutlinedButton(
                  text: "Refresh (async)",
                  onPressed: _refreshAsync,
                ),
              ],
            ),
            AET(
              "store",
              [
                LongOutlinedButton(
                  text: "_store (sync)",
                  onPressed: _store,
                ),
              ],
            ),
            AET(
              "connect do daemon",
              [
                LongOutlinedButton(
                  text: "_connectToDaemon (sync)",
                  onPressed: _connectToDaemon,
                ),
              ],
            ),
            AET(
              "monero.isLibOk",
              [
                LongOutlinedButton(
                  text: "monero.isLibOk",
                  onPressed: _isLibOk,
                ),
                if (libOk != null)
                  SelectableText(
                    const JsonEncoder.withIndent('    ').convert(libOk),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  monero.libOk? libOk;

  void _isLibOk() {
    setState(() {
      libOk = monero.isLibOk();
    });
  }
}
