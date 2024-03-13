import 'package:flutter/material.dart';
import 'package:xmruw/pages/pos/items_catalogue.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';

class PoSHomePage extends StatelessWidget {
  const PoSHomePage({super.key});

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const PoSHomePage();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PoS"),
      ),
      body: Column(
        children: [
          const Text(
            "Welcome to PoS mode. Here you can easily sell your products and accept monero in exchange.",
          ),
          LongOutlinedButton(
            text: "Items list",
            onPressed: () {
              ItemsCataloguePage.push(context);
            },
          )
        ],
      ),
    );
  }
}
