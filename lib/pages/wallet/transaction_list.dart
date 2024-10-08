import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/helpers/platform_support.dart';
import 'package:xmruw/helpers/resource.g.dart';
import 'package:xmruw/legacy.dart';
import 'package:xmruw/pages/changelog.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/debug/performance.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/pages/scanner/base_scan.dart';
import 'package:xmruw/pages/scanner/scanner_text_only.dart';
import 'package:xmruw/pages/wallet/outputs_page.dart';
import 'package:xmruw/tools/format_monero.dart';
import 'package:xmruw/tools/is_offline.dart';
import 'package:xmruw/tools/monero/account_index.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_lock.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/transaction_list/popup_menu.dart';
import 'package:xmruw/widgets/transaction_list/transaction_item.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

monero.TransactionHistory? txHistoryPtrVar;
monero.TransactionHistory get txHistoryPtr {
  txHistoryPtrVar ??= monero.Wallet_history(walletPtr!);
  return txHistoryPtrVar!;
}

class _TransactionListState extends State<TransactionList> {
  late int transactionCount = monero.TransactionHistory_count(txHistoryPtr);
  Timer? refresh;
  @override
  void initState() {
    _loadChangelogLength();
    refresh = Timer.periodic(const Duration(seconds: 1), _timerCallback);
    _timerCallback(refresh!);
    super.initState();
  }

  void _loadChangelogLength() async {
    final str = await rootBundle.loadString(R.ASSETS_CHANGELOG_JSONP);
    setState(() {
      changelogLength = str.split("\n").length;
    });
  }

  void _timerCallback(Timer timer) {
    _synchronized();
    if (!synchronized) return;
    if (!mounted) return;
    final newElms = _buildTxList();
    if (newElms.length != transactionCount) {
      setState(() {
        transactionCount = newElms.length;
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

  void _lockWallet() {
    if (!config.enableBackgroundSync) {
      print("enableBackgroundSync == false - refusing to _lockWallet");
      return;
    }
    if (tempWalletPassword != "") {
      final stat = monero.Wallet_setupBackgroundSync(
        walletPtr!,
        backgroundSyncType: 1,
        walletPassword: tempWalletPassword,
        backgroundCachePassword: "",
      );
      if (!stat) {
        Alert(title: monero.Wallet_errorString(walletPtr!), cancelable: true)
            .show(context);
        return;
      }
      tempWalletPassword = "";
    }
    final status = monero.Wallet_startBackgroundSync(walletPtr!);
    if (!status) {
      Alert(
        title: monero.Wallet_errorString(walletPtr!),
        cancelable: true,
      ).show(context);
      return;
    }
    PinScreen.pushLock(context);
  }

  void _synchronized() {
    setState(() {
      synchronized = monero.Wallet_synchronized(walletPtr!);
    });
  }

  bool synchronized = monero.Wallet_synchronized(walletPtr!);

  Widget? _drawer() {
    if (config.experimentalAccounts == false) return null;
    // if (MONERO_Wallet_numSubaddressAccounts(walletPtr!) == 1) return null;
    final count = monero.Wallet_numSubaddressAccounts(walletPtr!);
    return Drawer(
      child: ListView.builder(
        itemCount: count + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _getTopWidget();
          }
          if (index == count + 1) {
            return InkWell(
              onTap: () {
                setState(() {});
                monero.Wallet_addSubaddressAccount(walletPtr!);
              },
              child: const ListTile(
                leading: Icon(Icons.add),
                title: Text("Add another"),
              ),
            );
          }

          final balance = monero.Wallet_balance(
            walletPtr!,
            accountIndex: index - 1,
          );

          return Column(
            children: [
              InkWell(
                onTap: () {
                  globalAccountIndex = index - 1;
                  setState(() {
                    txList = _buildTxList();
                  });
                },
                child: ListTile(
                  title: Text("#${index - 1}. ${formatMonero(balance)}"),
                  subtitle: Text(formatMoneroFiat(balance, null)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _getTopWidget() {
    int balTotal = 0;
    final accounts = monero.Wallet_numSubaddressAccounts(walletPtr!);
    for (var i = 0; i < accounts; i++) {
      balTotal += monero.Wallet_balance(walletPtr!, accountIndex: i);
    }
    return Container(
      color: Theme.of(context).cardColor,
      height: 130,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatMonero(balTotal), style: const TextStyle(fontSize: 24)),
            Text(formatMoneroFiat(balTotal, null)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: LinearProgressIndicator(
            value: DateTime.now().difference(lastClick).inSeconds / lockAfter),
        automaticallyImplyLeading: false,
        leading: config.experimentalAccounts ? const DrawerButton() : null,
        title: SelectableText(getAppName()),
        actions: [
          if (config.enableBackgroundSync)
            IconButton(
              onPressed: _lockWallet,
              icon: const Icon(Icons.lock),
            ),
          if (canPlatformScan())
            IconButton(
              onPressed: () => BaseScannerPage.push(context),
              icon: const Icon(Icons.crop_free_sharp),
            ),
          if (canPlatformText())
            IconButton(
              onPressed: () => ScannerTextOnly.push(context),
              icon: const Icon(Icons.code),
            ),
          TxListPopupMenu()
        ],
      ),
      drawer: _drawer(),
      body: ListView.builder(
        itemCount: /* !synchronized ? 3 : */ txList.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) return const LargeBalanceWidget();
          if (index == 1) return const SyncProgress();
          // if (txList[index -2 ])
          return TransactionItem(transaction: txList[index - 2]);
        },
      ),
      floatingActionButton: _fab(),
    );
  }

  int? changelogLength;

  Widget? _fab() {
    if (changelogLength == null) return null;
    if (changelogLength == config.lastChangelogVersion) return null;
    return FloatingActionButton.extended(
      onPressed: _openChangelog,
      label: const Text("Changelog"),
      icon: const Icon(Icons.edit),
    );
  }

  void _openChangelog() {
    config.lastChangelogVersion = changelogLength ?? -1;
    config.save();
    ChangelogPage.push(context);
  }

  List<Transaction> _buildTxList() {
    monero.TransactionHistory_refresh(txHistoryPtr);
    transactionCount = monero.TransactionHistory_count(txHistoryPtr);
    final txList = List.generate(
      transactionCount,
      (index) => Transaction(
        txInfo: monero.TransactionHistory_transaction(txHistoryPtr,
            index: transactionCount - 1 - index),
      ),
    );
    txList
        .sort((tx1, tx2) => tx2.timeStamp.difference(tx1.timeStamp).inSeconds);
    txList.removeWhere((element) => element.accountIndex != globalAccountIndex);
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

  int blockChainHeight = monero.Wallet_blockChainHeight(walletPtr!);
  int uiHeight = monero.Wallet_blockChainHeight(walletPtr!);
  int daemonBlockchainHeight = kDebugMode
      ? monero.Wallet_daemonBlockChainHeight(walletPtr!)
      : monero.Wallet_daemonBlockChainHeight_cached(walletPtr!);
  bool? synchronized;
  void _refreshState() {
    setState(() {
      synchronized = monero.Wallet_synchronized(walletPtr!);
      blockChainHeight = monero.Wallet_blockChainHeight(walletPtr!);
      if (!kDebugMode) {
        daemonBlockchainHeight =
            monero.Wallet_daemonBlockChainHeight_cached(walletPtr!);
      }
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
    if (isOffline) {
      return const SizedBox(height: 50);
    }
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
  int balance = monero.Wallet_unlockedBalance(walletPtr!,
      accountIndex: globalAccountIndex);

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
    // int bal = 0;
    // final count =monero.Wallet_numSubaddressAccounts(walletPtr!);
    // for (int i = 0; i < count; i++) {
    //   bal +=monero.Wallet_balance(walletPtr!, accountIndex: 0);
    // }
    setState(() {
      balance = monero.Wallet_unlockedBalance(walletPtr!,
          accountIndex: globalAccountIndex);
    });
  }

  bool isFiat = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isFiat = !isFiat;
        });
      },
      onLongPress: () => OutputsPage.push(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, bottom: 10),
          child: Text(
            isFiat ? formatMoneroFiat(balance, null) : formatMonero(balance),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}

String getAppName() {
  final date = DateTime.now();
  if (date.day == 14 && date.month == 2) return "xmr uwu :3";
  if (date.day == 1 && date.month == 4) return "Zcash Wallet";
  if (date.day == 18 && date.month == 4) return "happy b day xmr!";
  if (Random.secure().nextInt(1000) == 69) return "xmr uwu :3";
  return "xmruw";
}
