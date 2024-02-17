import 'dart:io';

import 'package:xmruw/pages/crypto/crypto.dart';
import 'package:xmruw/pages/sync_static_progress.dart';
import 'package:xmruw/pages/ur_broadcast.dart';
import 'package:xmruw/pages/wallet/settings_page.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/is_offline.dart';
import 'package:xmruw/tools/is_view_only.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/urqr.dart';
import 'package:bytewords/bytewords.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

Future<void> exportOutputs(BuildContext c) async {
  final p = await getMoneroExportOutputsPath();
  if (File(p).existsSync()) File(p).deleteSync();
  final stat = MONERO_Wallet_exportOutputs(walletPtr!, p, all: true);
  if (!stat) {
    // ignore: use_build_context_synchronously
    await Alert(
      title: MONERO_Wallet_errorString(walletPtr!),
      cancelable: true,
    ).show(c);
    return;
  }
  // ignore: use_build_context_synchronously
  await UrBroadcastPage.push(
    c,
    filePath: p,
    flag: UrBroadcastPageFlag.xmrOutputs,
  );
}

void exportKeyImages(BuildContext c) async {
  final p = await getMoneroExportKeyImagesPath();
  MONERO_Wallet_exportKeyImages(walletPtr!, p, all: true);
  final status = MONERO_Wallet_status(walletPtr!);
  if (status != 0) {
    // ignore: use_build_context_synchronously
    await Alert(title: MONERO_Wallet_errorString(walletPtr!), cancelable: true)
        .show(c);
    return;
  }
  // ignore: use_build_context_synchronously
  await UrBroadcastPage.push(
    c,
    filePath: p,
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
    MONERO_Wallet_rescanBlockchainAsync(walletPtr!);
    MONERO_Wallet_refreshAsync(walletPtr!);
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
        MONERO_Wallet_importOutputs(walletPtr!, p.files.first.path!);
      } catch (e) {
        // ignore: use_build_context_synchronously
        await Alert(title: "$e", cancelable: true).show(c);
        return;
      }
      final status = MONERO_Wallet_status(walletPtr!);
      if (status != 0) {
        // ignore: use_build_context_synchronously
        await Alert(
                title: MONERO_Wallet_errorString(walletPtr!), cancelable: true)
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
      final MONERO_UnsignedTransaction utx = MONERO_Wallet_loadUnsignedTx(
          walletPtr!,
          unsigned_filename: p.files.first.path!);
      final status = MONERO_Wallet_status(walletPtr!);
      if (status != 0) {
        // ignore: use_build_context_synchronously
        await Alert(
                title: MONERO_Wallet_errorString(walletPtr!), cancelable: true)
            .show(c);
        return;
      }
      final signedFileName = await getMoneroSignedTxPath();
      final res = MONERO_UnsignedTransaction_sign(utx, signedFileName);
      final status2 = MONERO_Wallet_status(walletPtr!);
      if (status2 != 0 || res == false) {
        // ignore: use_build_context_synchronously
        await Alert(
                title: MONERO_Wallet_errorString(walletPtr!), cancelable: true)
            .show(c);
        return;
      }
      // ignore: use_build_context_synchronously
      await Alert(
        singleBody: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: URQR(
            frames: uint8ListToURQR(
              File(signedFileName).readAsBytesSync(),
              "xmr-txsigned",
              fragLength: 200,
            ),
          ),
        ),
        cancelable: true,
        callback: () => CRFileSaver.saveFileWithDialog(SaveFileDialogParams(
            sourceFilePath: signedFileName,
            destinationFileName: 'signed_transaction')),
        callbackText: "File",
      ).show(c);
    });
  }

  void _onSelected(BuildContext c, TxListPopupAction action) {
    switch (action) {
      case TxListPopupAction.resync:
        _resync();
        break;
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
      default:
        Alert(title: "$action").show(c);
    }
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
      MONERO_Wallet_importOutputs(walletPtr!, p.files.first.path!);
    } catch (e) {
      // ignore: use_build_context_synchronously
      await Alert(title: "$e", cancelable: true).show(c);
      return;
    }
    final stat =
        MONERO_Wallet_submitTransaction(walletPtr!, p.files.single.path!);
    if (!stat) {
      // ignore: use_build_context_synchronously
      Alert(
        title: MONERO_Wallet_errorString(walletPtr!),
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
    TxListPopupAction.resync,
    if (isOffline) TxListPopupAction.exportKeyImages,
    if (isViewOnly) TxListPopupAction.exportOutputs,
    if (isViewOnly) TxListPopupAction.broadcastTx,
    if (isOffline) TxListPopupAction.signTx,
    if (isOffline) TxListPopupAction.importOutputs,
    TxListPopupAction.crypto,
    TxListPopupAction.settings
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
  crypto
}
