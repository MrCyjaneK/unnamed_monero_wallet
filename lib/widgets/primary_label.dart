import 'package:flutter/material.dart';

class PrimaryLabel extends StatelessWidget {
  final String title;
  final bool expand;
  const PrimaryLabel({
    super.key,
    required this.title,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: SizedBox(
        width: expand ? double.maxFinite : null,
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}
