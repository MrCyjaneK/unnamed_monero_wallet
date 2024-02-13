import 'dart:convert';

import 'package:xmruw/tools/backup_class.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class BackupTestDebug extends StatefulWidget {
  const BackupTestDebug({super.key});

  @override
  State<BackupTestDebug> createState() => _BackupTestDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const BackupTestDebug();
      },
    ));
  }
}

class _BackupTestDebugState extends State<BackupTestDebug> {
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
