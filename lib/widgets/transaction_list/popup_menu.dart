import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/crypto/crypto.dart';
import 'package:xmruw/pages/pos/home.dart';
import 'package:xmruw/pages/sync_static_progress.dart';
import 'package:xmruw/pages/ur_broadcast.dart';
import 'package:xmruw/pages/usage_graphs.dart';
import 'package:xmruw/pages/wallet/outputs_page.dart';
import 'package:xmruw/pages/wallet/settings_page.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/is_offline.dart';
import 'package:xmruw/tools/is_view_only.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/urqr.dart';

Future<void> exportOutputs(BuildContext c) async {
  final ur = monero.Wallet_exportOutputsUR(walletPtr!, all: true);
  final status = monero.Wallet_status(walletPtr!);
  if (status != 0) {
    // ignore: use_build_context_synchronously
    await Alert(
      title: monero.Wallet_errorString(walletPtr!),
      cancelable: true,
    ).show(c);
    return;
  }
  // ignore: use_build_context_synchronously
  await UrBroadcastPage.push(
    c,
    content: ur,
    flag: UrBroadcastPageFlag.xmrOutputs,
  );
}

void exportKeyImages(BuildContext c) async {
  final p = await getMoneroExportKeyImagesPath();
  monero.Wallet_exportKeyImages(walletPtr!, p, all: true);
  final status = monero.Wallet_status(walletPtr!);
  if (status != 0) {
    // ignore: use_build_context_synchronously
    await Alert(title: monero.Wallet_errorString(walletPtr!), cancelable: true)
        .show(c);
    return;
  }
  // ignore: use_build_context_synchronously
  await UrBroadcastPage.push(
    c,
    content: File(p).readAsStringSync(),
    flag: UrBroadcastPageFlag.xmrKeyImage,
  );
}

class TxListPopupMenu extends StatelessWidget {
  TxListPopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TxListPopupAction>(
      onSelected: (action) => _onSelected(context, action),
      itemBuilder: (context) => _getWidgets(),
    );
  }

  void _resync() {
    monero.Wallet_rescanBlockchainAsync(walletPtr!);
    monero.Wallet_refreshAsync(walletPtr!);
  }

  void _importOutputs(BuildContext c) async {
    SyncStaticProgress.push(c, "Import outputs", () async {
      final p = await FilePicker.platform.pickFiles();

      if (p == null) {
        // ignore: use_build_context_synchronously
        await Alert(title: "No file picked", cancelable: true).show(c);
        return;
      }
      try {
        monero.Wallet_importOutputs(walletPtr!, p.files.first.path!);
      } catch (e) {
        // ignore: use_build_context_synchronously
        await Alert(title: "$e", cancelable: true).show(c);
        return;
      }
      final status = monero.Wallet_status(walletPtr!);
      if (status != 0) {
        // ignore: use_build_context_synchronously
        await Alert(
                title: monero.Wallet_errorString(walletPtr!), cancelable: true)
            .show(c);
        return;
      }
    });
  }

  void _signTx(BuildContext c) async {
    SyncStaticProgress.push(c, "Sign transaction", () async {
      final p = await FilePicker.platform.pickFiles();

      if (p == null) {
        // ignore: use_build_context_synchronously
        await Alert(title: "No file picked", cancelable: true).show(c);
        return;
      }
      final monero.UnsignedTransaction utx = monero.Wallet_loadUnsignedTx(
          walletPtr!,
          unsigned_filename: p.files.first.path!);
      final status = monero.Wallet_status(walletPtr!);
      if (status != 0) {
        // ignore: use_build_context_synchronously
        await Alert(
                title: monero.Wallet_errorString(walletPtr!), cancelable: true)
            .show(c);
        return;
      }
      final res = monero.UnsignedTransaction_signUR(utx, 130);
      final status2 = monero.Wallet_status(walletPtr!);
      if (status2 != 0 || res == false) {
        // ignore: use_build_context_synchronously
        await Alert(
                title: monero.Wallet_errorString(walletPtr!), cancelable: true)
            .show(c);
        return;
      }
      // ignore: use_build_context_synchronously
      await Alert(
        singleBody: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: URQR(frames: res.split("\n")),
        ),
        cancelable: true,
        callbackText: "File",
      ).show(c);
    });
  }

  void _onSelected(BuildContext c, TxListPopupAction action) {
    switch (action) {
      case TxListPopupAction.resync:
        _resync();
      case TxListPopupAction.exportKeyImages:
        exportKeyImages(c);
      case TxListPopupAction.exportOutputs:
        exportOutputs(c);
      case TxListPopupAction.broadcastTx:
        _broadcastTx(c);
      case TxListPopupAction.importOutputs:
        _importOutputs(c);
      case TxListPopupAction.signTx:
        _signTx(c);
      case TxListPopupAction.settings:
        _openSettings(c);
      case TxListPopupAction.crypto:
        _openCrypto(c);
      case TxListPopupAction.saveexit:
        _saveExit(c);
      case TxListPopupAction.coinControl:
        OutputsPage.push(c);
      case TxListPopupAction.graphs:
        UsageGraphsPage.push(c);
      case TxListPopupAction.pos:
        PoSHomePage.push(c);
    }
  }

  void _saveExit(BuildContext c) async {
    Alert(title: "Saving and closing...").show(c);
    monero.Wallet_store(walletPtr!);
    await Future.delayed(const Duration(seconds: 1));
    exit(0);
  }

  void _openSettings(BuildContext c) {
    SettingsPage.push(c);
  }

  void _openCrypto(BuildContext c) {
    CryptoStuff.push(c);
  }

  void _broadcastTx(BuildContext c) async {
    final p = await FilePicker.platform.pickFiles();

    if (p == null) {
      // ignore: use_build_context_synchronously
      await Alert(title: "No file picked", cancelable: true).show(c);
      return;
    }
    try {
      monero.Wallet_importOutputs(walletPtr!, p.files.first.path!);
    } catch (e) {
      // ignore: use_build_context_synchronously
      await Alert(title: "$e", cancelable: true).show(c);
      return;
    }
    final stat =
        monero.Wallet_submitTransaction(walletPtr!, p.files.single.path!);
    if (!stat) {
      // ignore: use_build_context_synchronously
      Alert(
        title: monero.Wallet_errorString(walletPtr!),
        cancelable: true,
      ).show(c);
      return;
    }
    // ignore: use_build_context_synchronously
    await Alert(
      title: "Broadcasted!",
      cancelable: true,
    ).show(c);
  }

  final enabledActions = [
    if (config.showExtraOptions || !isOffline) TxListPopupAction.resync,
    if (config.showExtraOptions || isOffline) TxListPopupAction.exportKeyImages,
    if (config.showExtraOptions || isViewOnly) TxListPopupAction.exportOutputs,
    if (config.showExtraOptions || isViewOnly) TxListPopupAction.broadcastTx,
    if (config.showExtraOptions || isOffline) TxListPopupAction.signTx,
    if (config.showExtraOptions || isOffline) TxListPopupAction.importOutputs,
    TxListPopupAction.crypto,
    TxListPopupAction.settings,
    if (config.showExtraOptions || config.enableGraphs)
      TxListPopupAction.graphs,
    if (config.showExtraOptions || config.enablePoS) TxListPopupAction.pos,
    TxListPopupAction.saveexit,
  ];

  List<PopupMenuItem<TxListPopupAction>> _getWidgets() {
    List<PopupMenuItem<TxListPopupAction>> list = [];
    for (var elm in enabledActions) {
      list.add(_getWidget(elm));
    }
    return list;
  }

  PopupMenuItem<TxListPopupAction> _getWidget(TxListPopupAction elm) {
    return switch (elm) {
      TxListPopupAction.resync => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.resync,
          child: Text('Resync Blockchain'),
        ),
      TxListPopupAction.exportKeyImages =>
        const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.exportKeyImages,
          child: Text('Export Key Images'),
        ),
      TxListPopupAction.exportOutputs => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.exportOutputs,
          child: Text('Export Outputs'),
        ),
      TxListPopupAction.broadcastTx => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.broadcastTx,
          child: Text('Broadcast Tx'),
        ),
      TxListPopupAction.signTx => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.signTx,
          child: Text('Sign Tx'),
        ),
      TxListPopupAction.importOutputs => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.importOutputs,
          child: Text('Import Outputs'),
        ),
      TxListPopupAction.coinControl => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.coinControl,
          child: Text('Coin Control'),
        ),
      TxListPopupAction.settings => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.settings,
          child: Text("Settings"),
        ),
      TxListPopupAction.crypto => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.crypto,
          child: Text("Sign/Verify"),
        ),
      TxListPopupAction.saveexit => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.saveexit,
          child: Text("Save & Exit"),
        ),
      TxListPopupAction.graphs => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.graphs,
          child: Text("Garphs"),
        ),
      TxListPopupAction.pos => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.pos,
          child: Text("PoS"),
        ),
    };
  }
}

enum TxListPopupAction {
  resync,
  exportKeyImages,
  exportOutputs,
  broadcastTx,
  signTx,
  importOutputs,
  coinControl,
  settings,
  crypto,
  saveexit,
  graphs,
  pos
}
