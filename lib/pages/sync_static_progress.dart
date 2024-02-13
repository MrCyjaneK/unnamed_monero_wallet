import 'dart:async';

import 'package:xmruw/widgets/setup_logo.dart';
import 'package:flutter/material.dart';

class SyncStaticProgress extends StatefulWidget {
  const SyncStaticProgress({super.key, required this.text, required this.func});
  final String text;

  final FutureOr<void> Function() func;

  @override
  State<SyncStaticProgress> createState() => _SyncStaticProgressState();
  static Future<void> push(
      BuildContext context, String text, FutureOr<void> Function() func) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return SyncStaticProgress(text: text, func: func);
      },
    ));
  }
}

class _SyncStaticProgressState extends State<SyncStaticProgress> {
  @override
  void initState() {
    super.initState();
    _doTaskDelayed();
  }

  void _doTaskDelayed() async {
    await Future.delayed(Duration.zero);
    await widget.func();
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SetupLogo(
          title: widget.text,
          width: 250,
        ),
      ),
    );
  }
}
