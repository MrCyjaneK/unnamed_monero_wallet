import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
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
    final cppcpp = monero.MONERO_checksum_wallet2_api_c_cpp();
    final cpph = monero.MONERO_checksum_wallet2_api_c_h();
    final cppexp = monero.MONERO_checksum_wallet2_api_c_exp();
    const dartcpp = monero.wallet2_api_c_cpp_sha256;
    const darth = monero.wallet2_api_c_h_sha256;
    const dartexp = monero.wallet2_api_c_exp_sha256;
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
              if (dartcpp != cppcpp) const Text("cpp mismatch"),
              if (darth != cpph) const Text("cpp mismatch"),
              if (dartexp != cppexp) const Text("exp mismatch"),
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
