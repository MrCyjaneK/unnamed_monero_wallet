import 'dart:convert';

import 'package:anonero/tools/node.dart';
import 'package:anonero/tools/proxy.dart';
import 'package:flutter/material.dart';

class VarsDebug extends StatefulWidget {
  const VarsDebug({super.key});

  @override
  State<VarsDebug> createState() => _VarsDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const VarsDebug();
      },
    ));
  }
}

class _VarsDebugState extends State<VarsDebug> {
  NodeStore? ns;
  Node? n;
  ProxyStore? ps;
  @override
  void initState() {
    super.initState();
    NodeStore.getNodes().then((value) {
      setState(() {
        ns = value;
      });
    });
    NodeStore.getCurrentNode().then((value) {
      setState(() {
        n = value;
      });
    });
    ProxyStore.getProxy().then((value) {
      setState(() {
        ps = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vars"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SelectableText("NodeStore: ${_debug(ns)}"),
            SelectableText("Node: ${_debug(n)}"),
            SelectableText("ProxyStore: ${_debug(ps)}"),
          ],
        ),
      ),
    );
  }

  String _debug(dynamic v) => const JsonEncoder.withIndent('    ').convert(v);
}
