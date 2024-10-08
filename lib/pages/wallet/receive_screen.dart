import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/pages/wallet/subaddress_page.dart';
import 'package:xmruw/tools/monero/account_index.dart';
import 'package:xmruw/tools/monero/subaddress_label.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/qr_code.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  late int currentAddressIndex = monero.Wallet_numSubaddresses(walletPtr!,
      accountIndex: globalAccountIndex);

  late String address = monero.Wallet_address(
    walletPtr!,
    accountIndex: globalAccountIndex,
    addressIndex: currentAddressIndex,
  );

  void _refreshAddr() {
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted) return;
      final ns = monero.Wallet_numSubaddresses(walletPtr!,
          accountIndex: globalAccountIndex);
      if (ns == currentAddressIndex) return;
      setState(() {
        currentAddressIndex = ns;
        address = monero.Wallet_address(
          walletPtr!,
          accountIndex: globalAccountIndex,
          addressIndex: currentAddressIndex,
        );
      });
    });
  }

  @override
  void initState() {
    _refreshAddr();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Receive"),
        actions: [
          IconButton(
            onPressed: () => SubAddressPage.push(context),
            icon: const Icon(Icons.history),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              subaddressLabel(currentAddressIndex),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Qr(
              data: address,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
            child: SelectableText(
              address,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 17),
            ),
          )
        ],
      ),
    );
  }
}
