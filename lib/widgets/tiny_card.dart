import 'package:flutter/material.dart';

class TinyCard extends StatelessWidget {
  final String text;
  const TinyCard(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.white10),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
