import 'dart:async';

import 'package:anonero/pages/wallet/subaddress_page.dart';
import 'package:anonero/tools/monero/subaddress_label.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/qr_code.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  late int currentAddressIndex =
      MONERO_Wallet_numSubaddresses(walletPtr!, accountIndex: 0);

  late String address = MONERO_Wallet_address(
    walletPtr!,
    accountIndex: 0,
    addressIndex: currentAddressIndex,
  );

  void _refreshAddr() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final ns = MONERO_Wallet_numSubaddresses(walletPtr!, accountIndex: 0);
      if (ns == currentAddressIndex) return;
      setState(() {
        currentAddressIndex = ns;
        address = MONERO_Wallet_address(
          walletPtr!,
          accountIndex: 0,
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
