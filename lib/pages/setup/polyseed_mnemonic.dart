import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/pages/wallet/wallet_home.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:xmruw/widgets/setup_logo.dart';

class PolyseedMnemonic extends StatelessWidget {
  PolyseedMnemonic({super.key});

  final words = monero.Wallet_getPolyseed(walletPtr!, passphrase: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SetupLogo(title: "POLYSEED MNEMONIC"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 8,
                  childAspectRatio: 4,
                  children: _buildSeedTiles(),
                ),
              ),
            ),
          ),
          LongOutlinedButton(
            text: "Finish",
            onPressed: () => WalletHome.push(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSeedTiles() {
    return List.generate(
        words.length, (index) => SeedTile(index: index, text: words[index]));
  }

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PolyseedMnemonic();
      },
    ));
  }
}

class SeedTile extends StatelessWidget {
  const SeedTile({super.key, required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('${index + 1}.'),
          SizedBox(
            width: 80,
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontSize: 14),
              textAlign: TextAlign.start,
            ),
          )
        ],
      ),
    );
  }
}
