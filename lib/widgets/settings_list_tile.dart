import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onClick;
  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 34),
      onTap: onClick,
      title: Opacity(opacity: onClick == null ? 0.6 : 1, child: Text(title)),
      subtitle: subtitle == null
          ? null
          : Opacity(
              opacity: onClick == null ? 0.6 : 1,
              child: Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
      trailing: trailing,
    );
  }
}
