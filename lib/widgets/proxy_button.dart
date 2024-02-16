import 'package:xmruw/main_clean.dart';
import 'package:xmruw/pages/setup/proxy_settings.dart';
import 'package:flutter/material.dart';

class ProxyButton extends StatelessWidget {
  const ProxyButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => ProxySettings.push(
        context,
      ),
      label: Text(
        disableProxy ? "DISABLED IN DEBUG" : "PROXY",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
            ),
      ),
      icon: const Icon(Icons.settings),
    );
  }
}
