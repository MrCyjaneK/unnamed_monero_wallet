import 'dart:async';

import 'package:anonero/const/app_name.dart';
import 'package:anonero/const/is_view_only.dart';
import 'package:anonero/legacy.dart';
import 'package:anonero/pages/debug/performance.dart';
import 'package:anonero/pages/wallet/outputs_page.dart';
import 'package:anonero/tools/format_monero.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/transaction_list/popup_menu.dart';
import 'package:anonero/widgets/transaction_list/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final txHistoryPtr = MONERO_Wallet_history(walletPtr!);
  late int transactionCount = MONERO_TransactionHistory_count(txHistoryPtr);

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      MONERO_TransactionHistory_refresh(txHistoryPtr);
      final newTxCount = MONERO_TransactionHistory_count(txHistoryPtr);
      if (newTxCount != transactionCount) {
        setState(() {
          transactionCount = newTxCount;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isViewOnly ? nero : anon),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.lock)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.crop_free)),
          TxListPopupMenu()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const LargeBalanceWidget(),
            const SyncProgress(),
            ...List.generate(
              transactionCount,
              (index) => TransactionItem(
                transaction: Transaction(
                  txHistoryPtr: txHistoryPtr,
                  txIndex: transactionCount - 1 - index,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SyncProgress extends StatefulWidget {
  const SyncProgress({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SyncProgressState createState() => _SyncProgressState();
}

const targetFrameRate = 120;

class _SyncProgressState extends State<SyncProgress> {
  Timer? refreshTimer;
  Timer? uiRefreshTimer;

  @override
  void initState() {
    _refreshState();
    refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _refreshState();
    });
    uiRefreshTimer = Timer.periodic(
        const Duration(microseconds: 1000000 ~/ targetFrameRate * 10), (timer) {
      if (!mounted) return;
      _refreshUi();
    });
    super.initState();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    uiRefreshTimer?.cancel();
    super.dispose();
  }

  int blockChainHeight = MONERO_Wallet_blockChainHeight(walletPtr!);
  int uiHeight = MONERO_Wallet_blockChainHeight(walletPtr!);
  int daemonBlockchainHeight = MONERO_Wallet_daemonBlockChainHeight(walletPtr!);
  bool? synchronized;
  void _refreshState() {
    setState(() {
      blockChainHeight = MONERO_Wallet_blockChainHeight(walletPtr!);
      daemonBlockchainHeight = MONERO_Wallet_daemonBlockChainHeight(walletPtr!);
      synchronized = MONERO_Wallet_synchronized(walletPtr!);
    });
  }

  double slideFor = 0;

  void _refreshUi() {
    if (uiHeight < blockChainHeight) {
      setState(() {
        slideFor += (blockChainHeight - uiHeight) / frameTime / 10;
        uiHeight +=
            (((blockChainHeight - uiHeight) / frameTime) + slideFor).ceil();
      });
    } else if (uiHeight > blockChainHeight) {
      setState(() {
        uiHeight = blockChainHeight;
      });
    } else if (slideFor != 0) {
      setState(() {
        slideFor = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (synchronized != true || uiHeight != daemonBlockchainHeight) {
      return SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (uiHeight / (daemonBlockchainHeight + 1)),
              ),
              Text(
                  "height: $uiHeight; ${(uiHeight / (daemonBlockchainHeight + 1)).toStringAsFixed(4)}% s:$synchronized"),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
    // retur
    return const SizedBox(height: 50);
  }
}

class LargeBalanceWidget extends StatefulWidget {
  const LargeBalanceWidget({super.key});

  @override
  State<LargeBalanceWidget> createState() => _LargeBalanceWidgetState();
}

class _LargeBalanceWidgetState extends State<LargeBalanceWidget> {
  int balance = MONERO_Wallet_unlockedBalance(walletPtr!, accountIndex: 0);

  @override
  void initState() {
    _refresh();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _refresh();
    });
    super.initState();
  }

  void _refresh() {
    int bal = 0;
    final count = MONERO_Wallet_numSubaddressAccounts(walletPtr!);
    for (int i = 0; i < count; i++) {
      bal += MONERO_Wallet_balance(walletPtr!, accountIndex: 0);
    }
    setState(() {
      balance = bal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => OutputsPage.push(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, bottom: 10),
          child: Text(
            formatMonero(balance),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}
