import 'dart:convert';

import 'package:flutter/material.dart';

class SET extends SimpleExpansionTile {
  const SET(super.title, super.body, {super.key});
}

class SimpleExpansionTile extends StatelessWidget {
  final String title;
  final dynamic body;
  const SimpleExpansionTile(
    this.title,
    this.body, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String text = "...";
    String? text2;
    try {
      text =
          "${body.runtimeType}(${const JsonEncoder.withIndent('    ').convert(body)})";
    } catch (e) {
      text = "${body.runtimeType}(${body.toString()})";
      text2 = "${e.runtimeType}($e)";
    }
    return ExpansionTile(
      title: Text(title),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.maxFinite,
            child: SelectableText(text),
          ),
        ),
        if (text2 != null) const Divider(),
        if (text2 != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.maxFinite,
              child: SelectableText(text2),
            ),
          ),
      ],
    );
  }
}
