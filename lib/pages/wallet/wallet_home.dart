import 'dart:io';

import 'package:xmruw/pages/wallet/receive_screen.dart';
import 'package:xmruw/pages/wallet/spend_screen.dart';
import 'package:xmruw/pages/wallet/transaction_list.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

enum Page { receive, home, send }

class WalletHome extends StatefulWidget {
  const WalletHome({super.key});

  @override
  State<WalletHome> createState() => WalletHomeState();

  static void push(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const WalletHome();
      },
    ));
  }
}

class WalletHomeState extends State<WalletHome> {
  Page page = Page.home;
  late final PageController _pageController =
      PageController(initialPage: page.index);
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (_pageController.page != Page.home.index) {
          _pageController.animateToPage(
            Page.home.index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.linear,
          );
          return;
        }
        if (!mounted) return;
        Alert(
          title: "Exit wallet?",
          callback: () {
            MONERO_Wallet_store(walletPtr!);
            exit(0);
          },
          callbackText: "Exit",
          cancelable: true,
        ).show(context);
      },
      canPop: false,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          children: const [
            ReceiveScreen(),
            TransactionList(),
            SpendScreen(),
          ],
          onPageChanged: (value) {
            setState(() {
              page = Page.values[value];
            });
          },
        ),
        bottomNavigationBar: BottomBar(
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          selectedIndex: page.index,
          onTap: (int index) {
            setState(() => page = Page.values[index]);
            _pageController.jumpToPage(index);
          },
          items: <BottomBarItem>[
            BottomBarItem(
              icon: const Icon(Icons.qr_code),
              title: const Text('Receive'),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            BottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text('Home'),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            BottomBarItem(
              icon: const Icon(Icons.send_outlined),
              title: const Text('Send'),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
