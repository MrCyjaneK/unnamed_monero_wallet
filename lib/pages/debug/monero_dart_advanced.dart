import 'dart:convert';

import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/advanced_expansion_tile.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

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
    final rsc = MONERO_Wallet_rescanBlockchain(walletPtr!);
    Alert(
            title: "result: $rsc\n"
                "status: ${MONERO_Wallet_status(walletPtr!)}\n"
                "errorString: ${MONERO_Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  void _rescanBlockchainAsync() {
    MONERO_Wallet_rescanBlockchainAsync(walletPtr!);
    Alert(
            title: "result: void\n"
                "status: ${MONERO_Wallet_status(walletPtr!)}\n"
                "errorString: ${MONERO_Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  void _refresh() {
    final rsc = MONERO_Wallet_refresh(walletPtr!);
    Alert(
            title: "result: $rsc\n"
                "status: ${MONERO_Wallet_status(walletPtr!)}\n"
                "errorString: ${MONERO_Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  void _store() {
    final rsc = MONERO_Wallet_store(walletPtr!);
    Alert(
            title: "result: $rsc\n"
                "status: ${MONERO_Wallet_status(walletPtr!)}\n"
                "errorString: ${MONERO_Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  void _connectToDaemon() {
    final rsc = MONERO_Wallet_connectToDaemon(walletPtr!);
    Alert(
            title: "result: $rsc\n"
                "status: ${MONERO_Wallet_status(walletPtr!)}\n"
                "errorString: ${MONERO_Wallet_errorString(walletPtr!)}",
            cancelable: true)
        .show(context);
  }

  void _refreshAsync() {
    MONERO_Wallet_refreshAsync(walletPtr!);
    Alert(
            title: "result: void\n"
                "status: ${MONERO_Wallet_status(walletPtr!)}\n"
                "errorString: ${MONERO_Wallet_errorString(walletPtr!)}",
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
              "MONERO_isLibOk",
              [
                LongOutlinedButton(
                  text: "MONERO_isLibOk",
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

  MONERO_libOk? libOk;

  void _isLibOk() {
    setState(() {
      libOk = MONERO_isLibOk();
    });
  }
}
