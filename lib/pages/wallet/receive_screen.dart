import 'package:anonero/pages/wallet/subaddress_page.dart';
import 'package:anonero/widgets/qr_code.dart';
import 'package:flutter/material.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  final address =
      '888tNkZrPN6JsEgekjMnABU4TBzc2Dt29EPAvkRxbANsAnjyPbb3iQ1YBRk1UXcdRsiKc9dhwMVgN5S9cQUiyoogDavup3H';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              "SUBADDRESS #3",
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
