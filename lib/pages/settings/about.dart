import 'package:flutter/material.dart';
import 'package:xmruw/helpers/licenses_extra.dart';
import 'package:xmruw/pages/settings/license_list_page.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:xmruw/widgets/setup_logo.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const AboutPage();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                width: double.maxFinite,
                child: SetupLogo(
                  title: "xmruw $xmruwVersion",
                ),
              ),
              const SelectableText(
                """
xmruw by mrcyjanek <cyjan@mrcyjanek.net>

Special thanks to:
- ofrnxmr for existing, keep up the good work!
- stack and cake for believing in the libs and me
- Mister_Magister and NotKit for help with SailfishOS

-------------

If you enjoy the wallet, please consider donating
83F5SjMRjE9UuaCUwso8zhix3DJEThnhcF8vTsCJ7zG3KiuKiqbyUshezKjmBwhqiAJP2KvzWNVRYVyBKaqpBwbp1cMD1FU
          """,
              ),
              LongOutlinedButton(
                text: "Licenses",
                onPressed: () => LicenseListPage.push(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}
