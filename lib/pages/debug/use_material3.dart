import 'dart:convert';
import 'dart:io';

import 'package:anonero/main.dart';
import 'package:anonero/tools/dirs.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class UseMaterial3Debug extends StatefulWidget {
  const UseMaterial3Debug({super.key});

  @override
  State<UseMaterial3Debug> createState() => _UseMaterial3DebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const UseMaterial3Debug();
      },
    ));
  }
}

class _UseMaterial3DebugState extends State<UseMaterial3Debug> {
  File? flagFile;
  @override
  void initState() {
    super.initState();
    getMaterial3FlagFile().then((value) {
      setState(() {
        flagFile = File(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (flagFile == null) return Container();
    return Scaffold(
      appBar: AppBar(
        title: const Text("use material3"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SelectableText("useMaterial3: ${_debug(useMaterial3)}"),
            SelectableText("flagFile: ${_debug(flagFile!.existsSync())}"),
            if (flagFile!.existsSync())
              LongOutlinedButton(
                text: "Destroy flag",
                onPressed: () {
                  flagFile!.deleteSync();
                  setState(() {});
                },
              ),
            if (!flagFile!.existsSync())
              LongOutlinedButton(
                text: "Create flag",
                onPressed: () {
                  flagFile!.createSync();
                  setState(() {});
                },
              ),
            if (flagFile!.existsSync() != useMaterial3)
              const SelectableText("restart needed"),
          ],
        ),
      ),
    );
  }

  String _debug(dynamic v) => const JsonEncoder.withIndent('    ').convert(v);
}
