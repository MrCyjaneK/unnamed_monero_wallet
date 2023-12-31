import 'dart:math';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

class PerformanceDebug extends StatefulWidget {
  const PerformanceDebug({super.key});

  @override
  State<PerformanceDebug> createState() => _PerformanceDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const PerformanceDebug();
      },
    ));
  }
}

const precalc = 1700298;

int getOpenWalletTime() {
  if (debugCallLength["MONERO_Wallet_init"] == null) {
    return precalc;
  }
  if (debugCallLength["MONERO_Wallet_init"]!.length != 1) {
    return precalc;
  }
  return debugCallLength["MONERO_Wallet_init"]![0];
}

final String perfInfo = """
---- Performance tuning
This page lists all calls that take place during the app runtime.-
As per Flutter docs we can read:
> Flutter aims to provide 60 frames per second (fps) performance, or 120 fps-
performance on devices capable of 120Hz updates.

With that in mind we will aim to render frames every 8.3ms (~8333 µs). It is-
however acceptable to reach 16.6 ms (~16666 µs) but we should also keep in mind-
that there are also UI costs that aren't part of this benchmark.

For some calls it is also acceptable to exceed this amount of time, for example-
MONERO_Wallet_init takes ~${getOpenWalletTime()}µs-
(${(getOpenWalletTime() / 16666).toStringAsFixed(2)} frames). That time would-
be unnaceptable in most situations but since we call this function only when-
opening the wallet it is completely fine to freeze the UI for the time being --
as the user won't even notice that something happened.

---- Details
count: how many times did we call this function
average: average execution time
min: fastest execution
max: slowest execution
95th: 95% of the time, the function is slower than this amount of time
"""
    .split("-\n")
    .join(" ");

const frameTime = 8333;
const frameGreenTier = frameTime ~/ 100;
const frameBlueTier = frameTime ~/ 10;
const frameBlueGreyTier = frameTime ~/ 2;
const frameYellowTier = frameTime;
const frameOrangeTier = frameTime * 2;

Color? perfc(num frame) {
  if (frame < frameGreenTier) return Colors.green;
  if (frame < frameBlueTier) return Colors.blue;
  if (frame < frameBlueGreyTier) return Colors.blueGrey;
  if (frame < frameGreenTier) return Colors.green;
  if (frame < frameYellowTier) return Colors.yellow;
  if (frame < frameOrangeTier) return Colors.orange;
  return Colors.red;
}

class _PerformanceDebugState extends State<PerformanceDebug> {
  List<Widget> widgets = [];

  @override
  void initState() {
    _buildWidgets();
    super.initState();
  }

  SelectableText cw(String text, Color? color) {
    return SelectableText(
      text,
      style: TextStyle(color: color),
    );
  }

  bool hideSingle = true;

  void _setHideSingle(bool? v) {
    setState(() {
      hideSingle = v ?? true;
    });
    _buildWidgets();
  }

  void _buildWidgets() {
    List<Widget> ws = [];
    ws.add(Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(perfInfo),
        CheckboxListTile(
          title: const Text("Hide single"),
          value: hideSingle,
          onChanged: _setHideSingle,
        ),
        cw("<   1% of a frame (max: $frameGreenTierµs)", Colors.green),
        cw("<  10% of a frame (max: $frameBlueTierµs)", Colors.blue),
        cw("<  50% of a frame (max: $frameBlueGreyTierµs)", Colors.blueGrey),
        cw("< 100% of a frame (max: $frameYellowTierµs)", Colors.yellow),
        cw("< 200% of a frame (max: $frameOrangeTierµs)", Colors.orange),
        cw("> 200% of a frame (UI junk visible)", Colors.red),
      ],
    ));
    debugCallLength.forEach((key, value) {
      if (hideSingle && value.length == 1) return;
      final avg = _avg(value);
      final min = _min(value);
      final max = _max(value);
      final np = _95(value);
      ws.add(
        Card(
          child: ListTile(
            title: Text(
              key,
              style: TextStyle(color: perfc(np)),
            ),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cw("count: ${value.length}", null),
                cw("average: ${_str(avg)}µs (~${_str(avg / (frameTime * 2) * 100)}%)",
                    perfc(avg)),
                cw("min: $minµs (~${_str(min / (frameTime * 2) * 100)})",
                    perfc(min)),
                cw("max: $maxµs (~${_str(max / (frameTime * 2) * 100)}%)",
                    perfc(max)),
                cw("95th: $npµs (~${_str(np / (frameTime * 2) * 100)}%)",
                    perfc(np)),
              ],
            ),
          ),
        ),
      );
    });
    setState(() {
      widgets = ws;
    });
  }

  int _min(List<int> l) {
    return l.reduce(min);
  }

  int _max(List<int> l) {
    return l.reduce(max);
  }

  int _95(List<int> l) {
    final l0 = l.toList();
    l0.sort();
    int i = (0.95 * l.length).ceil() - 1;
    return l0[i];
  }

  double _avg(List<int> l) {
    int c = 0;
    for (var i = 0; i < l.length; i++) {
      c += l[i];
    }
    return c / l.length;
  }

  String _str(num d) => d.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Performance debug"),
        actions: [
          IconButton(
            onPressed: _buildWidgets,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: widgets,
          ),
        ),
      ),
    );
  }
}
