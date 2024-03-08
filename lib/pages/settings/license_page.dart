import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xmruw/helpers/licenses.g.dart';

class LicensePageLocal extends StatelessWidget {
  const LicensePageLocal({super.key, required this.package});
  final Package package;
  static Future<void> push(BuildContext context, Package package) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return LicensePageLocal(package: package);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(package.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: Text("${package.name} v${package.version}"),
                  subtitle: Text(package.description),
                ),
              ),
              if (package.homepage != null)
                CopyIconButton(
                  icon: Icons.web,
                  uri: Uri.tryParse(package.homepage ?? ""),
                ),
              if (package.repository != null)
                CopyIconButton(
                  icon: Icons.source,
                  uri: Uri.tryParse(package.repository ?? ""),
                ),
              ...package.authors.toList().map((e) => SelectableText(e)),
              const Divider(),
              Text(package.license ?? "License text not found"),
            ],
          ),
        ),
      ),
    );
  }
}

class CopyIconButton extends StatelessWidget {
  const CopyIconButton({
    super.key,
    required this.icon,
    required this.uri,
  });

  final IconData icon;
  final Uri? uri;

  @override
  Widget build(BuildContext context) {
    if (uri == null) return const Text("broken uri. please report.");
    return SizedBox(
      width: double.maxFinite,
      child: ElevatedButton.icon(
        onPressed: () {
          Clipboard.setData(
            ClipboardData(text: uri.toString()),
          );
        },
        icon: Icon(icon),
        label: SizedBox(
          width: double.maxFinite,
          child: Text(uri?.host ?? "unknown"),
        ),
      ),
    );
  }
}
