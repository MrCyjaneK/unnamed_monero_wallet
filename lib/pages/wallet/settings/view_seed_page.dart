import 'package:anonero/const/app_name.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:anonero/widgets/padded_element.dart';
import 'package:anonero/widgets/primary_label.dart';
import 'package:anonero/widgets/qr_code.dart';
import 'package:anonero/widgets/tiny_card.dart';
import 'package:flutter/material.dart';

class ViewSeedPage extends StatefulWidget {
  const ViewSeedPage({super.key});

  @override
  State<ViewSeedPage> createState() => _ViewSeedPageState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ViewSeedPage();
      },
    ));
  }
}

class _ViewSeedPageState extends State<ViewSeedPage> {
  final address =
      '888tNkZrPN6JsEgekjMnABU4TBzc2Dt29EPAvkRxbANsAnjyPbb3iQ1YBRk1UXcdRsiKc9dhwMVgN5S9cQUiyoogDavup3H';

  final seed = [
    "bronze",
    "rough",
    "improve",
    "damage",
    "hammer",
    "source",
    "alpha",
    "letter",
    "spice",
    "front",
    "unhappy",
    "popular",
    "pen",
    "butter",
    "culture",
    "lumber"
  ];

  final legacySeed = [
    "eleven",
    "divers",
    "smash",
    "arrow",
    "dinner",
    "weekday",
    "bovine",
    "melting",
    "rarest",
    "jackets",
    "berries",
    "nirvana",
    "nexus",
    "symptoms",
    "volcano",
    "biweekly",
    "budget",
    "sake",
    "pixels",
    "coge",
    "licks",
    "napkin",
    "sedan",
    "spud",
    "jackets"
  ];

  bool useLegacy = false;

  void _toggleSeed() {
    setState(() {
      useLegacy = !useLegacy;
    });
  }

  void _showNeroKeys() {
    Alert(
      cancelable: false,
      body: [
        SizedBox(
          width: 512,
          child: Qr(
            data: seed.join("____"),
          ),
        )
      ],
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seed"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PrimaryLabel(title: "PRIMARY ADDRESS"),
              PaddedElement(child: SelectableText(address)),
              const Divider(),
              const PrimaryLabel(title: "POLYSEED MNEMONIC"),
              InkWell(
                onTap: _toggleSeed,
                child: PaddedElement(child: _seedWidget()),
              ),
              const Divider(),
              const PrimaryLabel(title: "VIEW-KEY"),
              PaddedElement(child: SelectableText(address)),
              const Divider(),
              const PrimaryLabel(title: "SPEND-KEY"),
              PaddedElement(child: SelectableText(address)),
              const Divider(),
              const PrimaryLabel(title: "RESTORE HEIGHT"),
              const PaddedElement(child: SelectableText('3011251')),
              const Divider(),
              LongOutlinedButton(
                text: "EXPORT $nero KEYS",
                onPressed: _showNeroKeys,
              )
            ],
          ),
        ),
      ),
    );
  }

  Wrap _seedWidget() {
    return Wrap(
      children: (useLegacy ? legacySeed : seed).map((e) {
        return TinyCard(e);
      }).toList(),
    );
  }
}
