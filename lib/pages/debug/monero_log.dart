import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xmruw/tools/dirs.dart';

class MoneroLogDebug extends StatefulWidget {
  const MoneroLogDebug({super.key});

  @override
  State<MoneroLogDebug> createState() => _MoneroLogDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const MoneroLogDebug();
      },
    ));
  }
}

class _MoneroLogDebugState extends State<MoneroLogDebug> {
  File? logFile;
  @override
  void initState() {
    super.initState();
    getMoneroLogPath().then((value) {
      if (!File(value).existsSync()) return;
      setState(() {
        logFile = File(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (logFile == null) return Container();
    return Scaffold(
      appBar: AppBar(title: const Text("monero logs"), actions: [
        IconButton(
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: logFile?.readAsStringSync() ?? "404"));
            },
            icon: const Icon(Icons.copy)),
      ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SelectableText(
              logFile?.readAsStringSync() ?? "file doesn't exist"),
        ),
      ),
    );
  }
}
