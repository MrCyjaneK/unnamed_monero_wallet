import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/pages/sync_static_progress.dart';
import 'package:xmruw/pages/wallet/spend_confirm.dart';
import 'package:xmruw/pages/wallet/spend_screen.dart';
import 'package:xmruw/pages/wallet/spend_success.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/transaction_list/popup_menu.dart';

Future<void> processUr(
    BuildContext context, String tag, List<String> urCodes) async {
  switch (tag) {
    case "debug":
      Alert(title: urCodes.join("\n"), cancelable: true).show(context);
    case "xmr-output":
      final ok = monero.Wallet_importOutputsUR(walletPtr!, urCodes.join("\n"));
      if (!ok) {
        // ignore: use_build_context_synchronously
        await Alert(
          title: monero.Wallet_errorString(walletPtr!),
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
        final preState = monero.Wallet_trustedDaemon(walletPtr!);
        monero.Wallet_setTrustedDaemon(walletPtr!, arg: true);
        final ok =
            monero.Wallet_importKeyImagesUR(walletPtr!, urCodes.join("\n"));
        if (!ok) {
          // ignore: use_build_context_synchronously
          Alert(
            title: monero.Wallet_errorString(walletPtr!),
            cancelable: true,
          ).show(context);
          monero.Wallet_setTrustedDaemon(walletPtr!, arg: preState);
          return;
        }
        monero.Wallet_setTrustedDaemon(walletPtr!, arg: preState);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      });
    case "xmr-txunsigned":
      final monero.UnsignedTransaction tx =
          monero.Wallet_loadUnsignedTxUR(walletPtr!, input: urCodes.join("\n"));
      if (monero.UnsignedTransaction_status(tx) != 0) {
        // ignore: use_build_context_synchronously
        await Alert(
          title: monero.UnsignedTransaction_errorString(tx),
          cancelable: true,
        ).show(context);
        return;
      }
      // ignore: use_build_context_synchronously
      SpendConfirm.pushReplace(
        context,
        TxRequest(
          address: monero.UnsignedTransaction_recipientAddress(tx),
          amount: (num.parse(monero.UnsignedTransaction_amount(tx))) ~/ 1,
          fee: (num.parse(monero.UnsignedTransaction_fee(tx))) ~/ 1,
          priority: Priority.default_,
          notes: "N/A",
          isSweep: false,
          outputs: [],
          isUR: true,
          txPtr: tx,
        ),
      );
    case "xmr-txsigned":
      final tx =
          monero.Wallet_submitTransactionUR(walletPtr!, urCodes.join("\n"));
      if (tx == false) {
        // ignore: use_build_context_synchronously
        await Alert(
          title: monero.Wallet_errorString(walletPtr!),
          cancelable: true,
        ).show(context);
        return;
      }
      // ignore: use_build_context_synchronously
      SpendSuccess.push(context);

    case _:
      Alert(
        singleBody: SelectableText(
          urCodes.join("\n"),
          style: const TextStyle(fontSize: 8),
        ),
        cancelable: true,
      ).show(context);
  }
}
