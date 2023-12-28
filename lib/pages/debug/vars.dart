import 'dart:io';

import 'package:flutter/material.dart';

class VarsDebug extends StatelessWidget {
  VarsDebug({super.key});

  final teCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vars"),
      ),
      body: Column(
        children: [
          SelectableText(File("a").absolute.path),
        ],
      ),
    );
  }

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return VarsDebug();
      },
    ));
  }
}
