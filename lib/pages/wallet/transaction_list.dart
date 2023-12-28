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

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

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
            TransactionItem(
                transaction: Transaction(
              confirmations: 3,
            )),
            TransactionItem(
              transaction: Transaction(confirmations: 9)
                ..amount = 1234567890120
                ..isSpend = true,
            ),
            TransactionItem(
                transaction: Transaction(confirmations: 25)..isSpend = true),
            TransactionItem(
                transaction: Transaction(confirmations: 90)
                  ..amount = 1234567890120),
            TransactionItem(transaction: Transaction(confirmations: 532)),
            TransactionItem(
                transaction: Transaction(confirmations: 53151)..isSpend = true),
            TransactionItem(transaction: Transaction(confirmations: 533135)),
            TransactionItem(transaction: Transaction(confirmations: 5111353)),
            TransactionItem(transaction: Transaction(confirmations: 532)),
            TransactionItem(transaction: Transaction(confirmations: 532)),
            TransactionItem(transaction: Transaction(confirmations: 532)),
            TransactionItem(transaction: Transaction(confirmations: 532)),
            TransactionItem(transaction: Transaction(confirmations: 532)),
            TransactionItem(transaction: Transaction(confirmations: 532)),
            TransactionItem(transaction: Transaction(confirmations: 532)),
          ],
        ),
      ),
    );
  }
}

class LargeBalanceWidget extends StatelessWidget {
  const LargeBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => OutputsPage.push(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, bottom: 60),
          child: Text(
            formatMonero(
                MONERO_Wallet_unlockedBalance(walletPtr!, accountIndex: 0)),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}
