import 'package:flutter/material.dart';

class LongElevatedButton extends StatelessWidget {
  const LongElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
  });
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 21.0),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 21,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
