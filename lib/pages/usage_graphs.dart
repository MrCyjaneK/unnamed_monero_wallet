import 'package:flutter/material.dart';

class UsageGraphsPage extends StatelessWidget {
  const UsageGraphsPage({super.key});

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const UsageGraphsPage();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Graphs"),
      ),
      body: const Column(
        children: [
          Text(
            "WIP",
          ),
        ],
      ),
    );
  }
}
