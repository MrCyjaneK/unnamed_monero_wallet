import 'package:flutter/material.dart';

class PrimaryLabel extends StatelessWidget {
  final String title;
  final bool expand;
  final bool enablePadding;
  final double? fontSize;
  final TextAlign textAlign;
  final FontWeight? fontWeight;
  final bool primary;
  const PrimaryLabel({
    super.key,
    required this.title,
    this.expand = true,
    this.enablePadding = true,
    this.fontSize,
    this.textAlign = TextAlign.left,
    this.fontWeight,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: !enablePadding
          ? const EdgeInsets.all(0)
          : const EdgeInsets.only(left: 16, top: 8),
      child: SizedBox(
        width: expand ? double.maxFinite : null,
        child: Text(
          title,
          textAlign: textAlign,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: primary
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
        ),
      ),
    );
  }
}
