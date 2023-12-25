import 'package:anonero/legacy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: transaction.isSpend
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 24,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getStats(transaction, context),
            Text(
              (((transaction.amount! / 1e12 * 1e4)).floor() / 1e4)
                  .toStringAsFixed(4),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Column(
              children: [
                Text(
                  formatTime(transaction.timeStamp),
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  getStats(Transaction transaction, BuildContext context) {
    if (!(transaction.isConfirmed)) {
      int confirms = transaction.confirmations;
      double progress = confirms / maxConfirms;
      return SizedBox(
        height: 30,
        width: 30,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.green,
              strokeWidth: 1,
              value: progress,
            ),
            Text(
              "$confirms",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.green, fontSize: 12),
            )
          ],
        ),
      );
    } else {
      return (transaction.isSpend)
          ? Icon(
              CupertinoIcons.arrow_up_right,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(CupertinoIcons.arrow_down_left);
    }
  }

  String formatTime(int? timestamp) {
    if (timestamp == null) {
      return "";
    }
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat("HH:mm\ndd/M").format(dateTime);
  }
}
