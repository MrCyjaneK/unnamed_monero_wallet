import 'dart:async';

import 'package:anonero/const/app_name.dart';
import 'package:anonero/const/is_view_only.dart';
import 'package:anonero/legacy.dart';
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

class _SyncProgressState extends State<SyncProgress> {
  @override
  void initState() {
    _refreshState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _refreshState();
    });
    super.initState();
  }

  int blockChainHeight = -1;
  int estimateBlockchainHeight = -1;
  bool? synchronized;
  int? connected;
  void _refreshState() {
    setState(() {
      blockChainHeight = MONERO_Wallet_blockChainHeight(walletPtr!);
      estimateBlockchainHeight =
          MONERO_Wallet_estimateBlockChainHeight(walletPtr!);
      synchronized = MONERO_Wallet_synchronized(walletPtr!);
      connected = MONERO_Wallet_connected(walletPtr!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText("""
blockChainHeight: $blockChainHeight
estimateBlockchainHeight: $estimateBlockchainHeight
synchronized: $synchronized
connected: $connected
""");
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
          padding: const EdgeInsets.only(top: 40.0, bottom: 60),
          child: Text(
            formatMonero(balance),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}
