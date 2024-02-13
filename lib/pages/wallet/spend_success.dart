import 'package:xmruw/pages/wallet/wallet_home.dart';
import 'package:flutter/material.dart';

class SpendSuccess extends StatelessWidget {
  const SpendSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.check_circle,
              size: 180,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Text("Successfully sent transaction."),
            TextButton(
              onPressed: () => _goHome(context),
              child: const Text("close"),
            ),
            const Spacer(flex: 2)
          ],
        ),
      ),
    );
  }

  void _goHome(BuildContext c) {
    WalletHome.push(c);
  }

  static void push(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const SpendSuccess();
      },
    ));
  }
}
