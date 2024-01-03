import 'dart:io';

import 'package:anonero/main.dart';
import 'package:anonero/tools/dirs.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class BootFlagDebug extends StatefulWidget {
  const BootFlagDebug({super.key});

  @override
  State<BootFlagDebug> createState() => _BootFlagDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const BootFlagDebug();
      },
    ));
  }
}

class _BootFlagDebugState extends State<BootFlagDebug> {
  File? material3Flag;
  File? poFlag;
  @override
  void initState() {
    super.initState();
    getMaterial3FlagFile().then((value) {
      setState(() {
        material3Flag = File(value);
      });
    });
    getShowPerformanceOverlayFlagFile().then((value) {
      setState(() {
        poFlag = File(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (material3Flag == null) return Container();
    return Scaffold(
      appBar: AppBar(
        title: const Text("use material3"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SelectableText("useMaterial3"),
            if (material3Flag!.existsSync())
              LongOutlinedButton(
                text: "Destroy flag",
                onPressed: () {
                  material3Flag!.deleteSync();
                  setState(() {});
                },
              ),
            if (!material3Flag!.existsSync())
              LongOutlinedButton(
                text: "Create flag",
                onPressed: () {
                  material3Flag!.createSync();
                  setState(() {});
                },
              ),
            const SelectableText("showPerformanceOverlay"),
            if (poFlag!.existsSync())
              LongOutlinedButton(
                text: "Destroy flag",
                onPressed: () {
                  poFlag!.deleteSync();
                  setState(() {});
                },
              ),
            if (!poFlag!.existsSync())
              LongOutlinedButton(
                text: "Create flag",
                onPressed: () {
                  poFlag!.createSync();
                  setState(() {});
                },
              ),
            if (material3Flag!.existsSync() != useMaterial3)
              const SelectableText("restart needed (material3)"),
            if (poFlag!.existsSync() != showPerformanceOverlay)
              const SelectableText("restart needed (showPerformanceOverlay)"),
          ],
        ),
      ),
    );
  }
}
