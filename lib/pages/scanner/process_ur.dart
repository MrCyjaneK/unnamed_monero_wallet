import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart';
import 'package:xmruw/pages/sync_static_progress.dart';
import 'package:xmruw/pages/wallet/spend_confirm.dart';
import 'package:xmruw/pages/wallet/spend_screen.dart';
import 'package:xmruw/pages/wallet/spend_success.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/hexdump.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/transaction_list/popup_menu.dart';

Future<void> processUr(BuildContext context, String tag, Uint8List data) async {
  switch (tag) {
    case "debug":
      Alert(title: utf8.decode(data), cancelable: true).show(context);
    case "xmr-output":
      final p = await getMoneroImportOutputsPath();
      File(p).writeAsBytesSync(data);
      final ok = MONERO_Wallet_importOutputs(walletPtr!, p);
      if (!ok) {
        // ignore: use_build_context_synchronously
        await Alert(
          title: MONERO_Wallet_errorString(walletPtr!),
          cancelable: true,
        ).show(context);
        return;
      }
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      exportKeyImages(context);
    case "xmr-keyimage":
      SyncStaticProgress.push(context, "IMPORTING KEY IMAGES", () async {
        await Future.delayed(const Duration(milliseconds: 100));
        final p = await getMoneroImportKeyImagesPath();
        File(p).writeAsBytesSync(data);
        final preState = MONERO_Wallet_trustedDaemon(walletPtr!);
        MONERO_Wallet_setTrustedDaemon(walletPtr!, arg: true);
        final ok = MONERO_Wallet_importKeyImages(walletPtr!, p);
        if (!ok) {
          // ignore: use_build_context_synchronously
          Alert(
            title: MONERO_Wallet_errorString(walletPtr!),
            cancelable: true,
          ).show(context);
          MONERO_Wallet_setTrustedDaemon(walletPtr!, arg: preState);
          return;
        }
        MONERO_Wallet_setTrustedDaemon(walletPtr!, arg: preState);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      });
    case "xmr-txunsigned":
      final p = await getMoneroUnsignedTxPath();
      if (File(p).existsSync()) File(p).deleteSync();
      File(p).writeAsBytesSync(data);
      final MONERO_UnsignedTransaction tx =
          MONERO_Wallet_loadUnsignedTx(walletPtr!, unsigned_filename: p);
      if (MONERO_UnsignedTransaction_status(tx) != 0) {
        // ignore: use_build_context_synchronously
        await Alert(
          title: MONERO_UnsignedTransaction_errorString(tx),
          cancelable: true,
        ).show(context);
        return;
      }
      // ignore: use_build_context_synchronously
      SpendConfirm.pushReplace(
        context,
        TxRequest(
          address: MONERO_UnsignedTransaction_recipientAddress(tx),
          amount: (num.parse(MONERO_UnsignedTransaction_amount(tx))) ~/ 1,
          fee: (num.parse(MONERO_UnsignedTransaction_fee(tx))) ~/ 1,
          priority: Priority.default_,
          notes: "N/A",
          isSweep: false,
          outputs: [],
          isUR: true,
          txPtr: tx,
        ),
      );
    case "xmr-txsigned":
      final p = await getMoneroSignedTxPath();
      File(p).writeAsBytesSync(data);
      final tx = MONERO_Wallet_submitTransaction(walletPtr!, p);
      if (tx == false) {
        // ignore: use_build_context_synchronously
        await Alert(
          title: MONERO_Wallet_errorString(walletPtr!),
          cancelable: true,
        ).show(context);
        return;
      }
      // ignore: use_build_context_synchronously
      SpendSuccess.push(context);

    case _:
      Alert(
        singleBody: SelectableText(
          hexDump(data),
          style: const TextStyle(fontSize: 8),
        ),
        cancelable: true,
      ).show(context);
  }
}
