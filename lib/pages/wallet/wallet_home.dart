import 'package:anonero/pages/wallet/receive_screen.dart';
import 'package:anonero/pages/wallet/settings_page.dart';
import 'package:anonero/pages/wallet/spend_screen.dart';
import 'package:anonero/pages/wallet/transaction_list.dart';
import 'package:anonero/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';

enum Page { home, receive, send, settings }

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
      canPop: false,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          children: const [
            TransactionList(),
            ReceiveScreen(),
            SpendScreen(),
            SettingsPage(),
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
              icon: const Icon(Icons.home),
              title: const Text('Home'),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            BottomBarItem(
              icon: const Icon(Icons.qr_code),
              title: const Text('Receive'),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            BottomBarItem(
              icon: const Icon(Icons.send_outlined),
              title: const Text('Send'),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            BottomBarItem(
              icon: const Icon(Icons.settings),
              title: const Text('Settings'),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
