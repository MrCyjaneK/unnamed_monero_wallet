import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xmruw/pages/config/base.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  static Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ConfigPage();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JSON config"),
      ),
      body: SingleChildScrollView(
        child: SelectableText(
          const JsonEncoder.withIndent('    ').convert(
            config.toJson(),
          ),
        ),
      ),
    );
  }
}
