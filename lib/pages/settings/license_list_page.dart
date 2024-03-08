import 'package:flutter/material.dart';
import 'package:xmruw/helpers/licenses_extra.dart';
import 'package:xmruw/pages/settings/license_page.dart';

class LicenseListPage extends StatefulWidget {
  const LicenseListPage({super.key});
  static Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const LicenseListPage();
      },
    ));
  }

  @override
  State<LicenseListPage> createState() => _LicenseListPageState();
}

class _LicenseListPageState extends State<LicenseListPage> {
  bool showAll = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Licenses"),
        actions: [
          const Text("Show All"),
          Checkbox(
              value: showAll,
              onChanged: (_) {
                setState(() {
                  showAll = !showAll;
                });
              })
        ],
      ),
      body: ListView.builder(
        itemCount: allLicenses.length,
        itemBuilder: (context, index) {
          if (!showAll &&
              !importantLicenses.contains(allLicenses[index].name)) {
            return Container();
          }
          final license = getLicenseName(allLicenses[index].name);
          return ListTile(
            onTap: () {
              LicensePageLocal.push(context, allLicenses[index]);
            },
            title: Text(
              allLicenses[index].name,
              maxLines: 1,
            ),
            subtitle: Text(
              license,
              style: TextStyle(
                  color: (allLicenses[index].license == null)
                      ? Colors.orangeAccent
                      : null),
            ),
            trailing: Text(allLicenses[index].version),
          );
        },
      ),
    );
  }
}
