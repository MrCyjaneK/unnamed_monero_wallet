import 'package:flutter/material.dart';

class PaddedElement extends StatelessWidget {
  const PaddedElement({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(width: double.maxFinite, child: child),
    );
  }
}
