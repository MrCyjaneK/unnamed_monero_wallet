import 'dart:io';

import 'package:xmruw/main_clean.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
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
  File? disableProxyFlag;
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
    getDisableProxyFlagFile().then((value) {
      setState(() {
        disableProxyFlag = File(value);
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
            const SelectableText("Disable proxy"),
            if (disableProxyFlag!.existsSync())
              LongOutlinedButton(
                text: "Destroy flag",
                onPressed: () {
                  disableProxyFlag!.deleteSync();
                  setState(() {});
                },
              ),
            if (!disableProxyFlag!.existsSync())
              LongOutlinedButton(
                text: "Create flag",
                onPressed: () {
                  disableProxyFlag!.createSync();
                  setState(() {});
                },
              ),
            if (poFlag!.existsSync() != showPerformanceOverlay)
              const SelectableText("restart needed (showPerformanceOverlay)"),
            if (disableProxyFlag!.existsSync() != disableProxy)
              const SelectableText("restart needed (disableProxy)"),
          ],
        ),
      ),
    );
  }
}
