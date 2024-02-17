import 'package:flutter/material.dart';

class LongOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const LongOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.6 : 1,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 24),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 1.0, color: Colors.white),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 12, color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 6),
                ),
                onPressed: onPressed,
                child: Text(
                  text.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
