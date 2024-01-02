import 'package:anonero/pages/sync_static_progress.dart';
import 'package:anonero/tools/dirs.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

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

  void _exportKeyImages(BuildContext c) async {
    SyncStaticProgress.push(c, "Exporting key images", () async {
      final p = await getMoneroExportKeyImagesPath();
      MONERO_Wallet_exportKeyImages(walletPtr!, p, all: true);
      final status = MONERO_Wallet_status(walletPtr!);
      if (status != 0) {
        // ignore: use_build_context_synchronously
        await Alert(
                title: MONERO_Wallet_errorString(walletPtr!), cancelable: true)
            .show(c);
        return;
      }
      CRFileSaver.saveFileWithDialog(SaveFileDialogParams(
          sourceFilePath: p, destinationFileName: 'export_key_images'));
    });
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
    SyncStaticProgress.push(c, "Import outputs", () async {
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
    });
  }

  void _onSelected(BuildContext c, TxListPopupAction action) {
    switch (action) {
      case TxListPopupAction.resync:
        _resync();
        break;
      case TxListPopupAction.exportKeyImages:
        _exportKeyImages(c);
      case TxListPopupAction.importOutputs:
        _importOutputs(c);
      case TxListPopupAction.signTx:
        _signTx(c);
      default:
        Alert(title: " $action").show(c);
    }
  }

  final enabledActions = [
    TxListPopupAction.resync,
    TxListPopupAction.exportKeyImages,
    TxListPopupAction.importOutputs,
    TxListPopupAction.signTx,
    TxListPopupAction.coinControl
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
}
