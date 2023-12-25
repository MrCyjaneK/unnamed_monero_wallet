import 'dart:math';

import 'package:anonero/pages/wallet/subaddress_details.dart';
import 'package:anonero/tools/format_monero.dart';
import 'package:flutter/material.dart';

class SubAddressPage extends StatelessWidget {
  const SubAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subadddresses"),
        actions: [
          IconButton(onPressed: _addSubaddress, icon: const Icon(Icons.add))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            children: List.generate(
                    128,
                    (index) => SubaddressItem(
                        subaddressId: index,
                        label: 'SUBADDRESS #$index',
                        received: (index * 1234567890123 +
                                pow(1234567890123, index).toInt()) %
                            1987435691635,
                        squashedAddress:
                            'squashedAddresssquashedAddresssquashedAddresssquashedAddresssquashedAddresssquashedAddresssquashedAddresssquashedAddress'))
                .reversed
                .toList()),
      ),
    );
  }

  void _addSubaddress() {}

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const SubAddressPage();
      },
    ));
  }
}

class SubaddressItem extends StatelessWidget {
  final int subaddressId;
  final String label;
  final int received;
  final String squashedAddress;
  final bool shouldSquash;
  const SubaddressItem({
    super.key,
    required this.subaddressId,
    required this.label,
    required this.received,
    required this.squashedAddress,
    this.shouldSquash = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: !shouldSquash
          ? null
          : () =>
              SubaddressDetailsPage.push(context, subaddressId: subaddressId),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      title: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Text(
            formatMonero(received),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
      subtitle: Text(
        squash(squashedAddress),
      ),
    );
  }

  String squash(String s) {
    if (s.length < 10 || !shouldSquash) return s;
    return "${s.substring(0, 5)}...${s.substring(s.length - 5)}";
  }
}
