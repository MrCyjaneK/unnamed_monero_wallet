import 'dart:convert';

import 'package:anonero/tools/backup_class.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class TorTestDebug extends StatefulWidget {
  const TorTestDebug({super.key});

  @override
  State<TorTestDebug> createState() => _TorTestDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const TorTestDebug();
      },
    ));
  }
}

class _TorTestDebugState extends State<TorTestDebug> {
  var bd = BackupDetails();

  void _decrypt() async {
    final newBd = await BackupDetails.decrypt(context);
    setState(() {
      bd = newBd;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backup"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LongOutlinedButton(
              text: "Decrypt",
              onPressed: _decrypt,
            ),
            const Divider(),
            SelectableText(
              const JsonEncoder.withIndent('    ').convert(bd.metadata),
            )
          ],
        ),
      ),
    );
  }
}
