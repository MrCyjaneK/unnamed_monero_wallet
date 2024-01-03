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

final txHistoryPtr = MONERO_Wallet_history(walletPtr!);

class _TransactionListState extends State<TransactionList> {
  late int transactionCount = MONERO_TransactionHistory_count(txHistoryPtr);
  Timer? refresh;
  @override
  void initState() {
    refresh = Timer.periodic(const Duration(seconds: 1), _timerCallback);
    _timerCallback(refresh!);
    super.initState();
  }

  void _timerCallback(Timer timer) {
    if (!mounted) return;
    MONERO_TransactionHistory_refresh(txHistoryPtr);
    final newTxCount = MONERO_TransactionHistory_count(txHistoryPtr);
    final newElms = _buildTxList();
    if (newTxCount != transactionCount) {
      setState(() {
        transactionCount = newTxCount;
      });
      return;
    }
    bool rebuild = false;
    if (txList.length != newElms.length) {
      rebuild = true;
    } else {
      for (var i = 0; i < newElms.length; i++) {
        rebuild =
            rebuild || newElms[i].confirmations != txList[i].confirmations;
        rebuild = rebuild || newElms[i].description != txList[i].description;
      }
    }
    if (rebuild) {
      setState(() {
        txList = newElms;
      });
    }
  }

  @override
  void dispose() {
    refresh?.cancel();
    super.dispose();
  }

  late var txList = _buildTxList();

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
      body: ListView.builder(
        itemCount: txList.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) return const LargeBalanceWidget();
          if (index == 1) return const SyncProgress();
          return TransactionItem(transaction: txList[index - 2]);
        },
      ),
    );
  }

  List<Transaction> _buildTxList() {
    final txList = List.generate(
      transactionCount,
      (index) => Transaction(
        txHistoryPtr: txHistoryPtr,
        txIndex: transactionCount - 1 - index,
      ),
    );
    txList
        .sort((tx1, tx2) => tx2.timeStamp.difference(tx1.timeStamp).inSeconds);
    return txList.toList();
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
  int daemonBlockchainHeight =
      MONERO_Wallet_daemonBlockChainHeight_cached(walletPtr!);
  bool? synchronized;
  void _refreshState() {
    setState(() {
      synchronized = MONERO_Wallet_synchronized(walletPtr!);
      blockChainHeight = MONERO_Wallet_blockChainHeight(walletPtr!);
      daemonBlockchainHeight =
          MONERO_Wallet_daemonBlockChainHeight_cached(walletPtr!);
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
                value: daemonBlockchainHeight == 0
                    ? null
                    : (uiHeight / (daemonBlockchainHeight + 1)),
              ),
              if (daemonBlockchainHeight == 0) const Text("disconnected"),
              if (daemonBlockchainHeight != 0)
                Text(
                  "height: $uiHeight; ${(uiHeight / (daemonBlockchainHeight + 1) * 100).toStringAsFixed(4)}% s:$synchronized",
                ),
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
