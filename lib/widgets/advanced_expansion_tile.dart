import 'package:flutter/material.dart';

class AET extends AdvancedExpansionTile {
  const AET(super.title, super.body, {super.key});
}

class AdvancedExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> body;
  const AdvancedExpansionTile(
    this.title,
    this.body, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      children: body,
    );
  }
}
