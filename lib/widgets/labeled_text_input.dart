import 'package:flutter/material.dart';

class LabeledTextInput extends StatelessWidget {
  final String? label;
  final String hintText;
  final String? helperText;
  final TextEditingController ctrl;
  final VoidCallback? onEdit;
  final int? minLines;
  final int? maxLines;
  final bool? enabled;
  final Widget? suffixIcon;
  final Color? color;
  const LabeledTextInput({
    super.key,
    required this.label,
    this.hintText = "",
    required this.ctrl,
    this.helperText,
    this.onEdit,
    this.minLines,
    this.maxLines,
    this.enabled,
    this.suffixIcon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: (label == null)
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color ?? Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                    ),
              ),
            ),
      subtitle: TextField(
        enabled: enabled,
        minLines: minLines,
        maxLines: maxLines,
        controller: ctrl,
        onChanged: (_) => onEdit?.call(),
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
          helperText: helperText,
          helperMaxLines: 3,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hintText,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
