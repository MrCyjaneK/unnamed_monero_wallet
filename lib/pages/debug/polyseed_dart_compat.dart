import 'dart:io';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:polyseed/polyseed.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/wallet_manager.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';

class PolyseedDartCompatTestDebug extends StatefulWidget {
  const PolyseedDartCompatTestDebug({super.key});

  @override
  State<PolyseedDartCompatTestDebug> createState() => _PolyseedDartCompatTestDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const PolyseedDartCompatTestDebug();
      },
    ));
  }
}

enum PolyseedLanguage {
    czech,
    english,
    spanish,
    french,
    italian,
    japanese,
    korean,
    portuguese,
    chineseSimplified,
    chineseTraditional,
}

class PolyseedTestCase {
  PolyseedTestCase({
    required this.language,
    this.polyseedSource,
    this.polyseedDart,
    this.polyseedCPP,
    this.mnemonicDart,
    this.mnemonicCPP,
    this.addressSource,
    this.addressDart,
    this.addressCPP,
    this.spendKeySource,
    this.spendKeyDart,
    this.spendKeyCPP,
    this.error = const [],
  });
  final PolyseedLanguage language;
  String? polyseedSource;
  String? polyseedDart;
  String? polyseedCPP;
  String? mnemonicDart;
  String? mnemonicCPP;
  String? addressSource;
  String? addressDart;
  String? addressCPP;
  String? spendKeySource;
  String? spendKeyDart;
  String? spendKeyCPP;
  List<String?> error;
}

final defaultTestCases = <PolyseedTestCase>[
  PolyseedTestCase(
    language: PolyseedLanguage.czech,
    polyseedSource: "tampon zdaleka kohout bestie snad vozovna kritik obehnat polknout radiace valcha mladost molekula praktika nuda rozpad",
    addressSource: "47sdVoFvxLkTiyoc22G6T8XZd8V4fsgbDNBSaoWdoNV41j1BdGPZ2HDA3GYAacjdkhUTF1VBqEyJE3MgS3GUHTVYQnK1eJw",
    spendKeySource: "a276f175c6a986857446889ca5434437a2c0f6fbaac873cd28c9ee6d393fa708",
  ),
  PolyseedTestCase(
    language: PolyseedLanguage.english,
    polyseedSource: "tent question screen violin innocent consider enable art junk exhibit front enter fat actual radio change",
    addressSource: "48dcvC6GJWaG4CfcN5ZtBgZ8rmSoR7Ut4h7vnFSESCfWCw9A6Q3rTZpQCLUXweWpc6DAbBcb6QHVaikmL5AFRZHr5j3g6Cr",
    spendKeySource: "4b2e0438b986581a16a397dbc1d759e03c7d0c6a2664ec647700385caed96d0f",
  ),
  PolyseedTestCase(
    language: PolyseedLanguage.spanish,
    polyseedSource: "sello palma género bosque máscara árido porción tema cine medalla corbata riesgo culto náusea ópera cambio",
    addressSource: "471nRmFLWqXML89YgpT1jbffsb51R6ovQhhdGcUVo4DMLP8vxcz4A6B6JSviV8oLHZPMiuUYRPn5uVXWWNe8F1avBiQcfGQ",
    spendKeySource: "018299a60e4a6fc408323f3094fe819652a63e73395099e59224c7d49c2d9d0a",
  ),
  PolyseedTestCase(
    language: PolyseedLanguage.french,
    polyseedSource: "loisir sécréter imbiber roseau décaler douter antenne frisson prouesse séquence golfeur séminal rocheux maniable abdiquer cuivre",
    addressSource: "4748X34KjjALPMvVr1TgBFUVkjY6Gh4G32ozr4fzkDhpCg6W4cAVTdrAWK2zPmh7rpdu1dDzBCwMSRBmTcA2DUqpMhEfKUd",
    spendKeySource: "374f84620c9f231ab13c84e33bf965af76513b348609e02e666352c102b2f705",
  ),
  PolyseedTestCase(
    language: PolyseedLanguage.italian,
    polyseedSource: "otite rifugio labbro scippo chela minore benigno larga autista teorema esagono elevare ortensia evaso slogatura vano",
    addressSource: "48Ppy7mcTudDJztVRiy1qk9oHrh3KXV2VNfMrgSMh5xqKm5Ez2rNmnBji3mYcNz1yKULyzsbkRaFcGKvfRvazJqgSwqR2VN",
    spendKeySource: "2043855a057abb62b6b9dd0f8b064c67b7d12d60fd1daaaabcb450afd1079e06",
  ),
  PolyseedTestCase(
    language: PolyseedLanguage.japanese,
    polyseedSource: "そがい　うんどう　ゆうびんきょく　ちぬり　こふう　よくぼう　はんしゃ　まゆげ　おやゆび　ひりつ　そつぎょう　うわき　こうてい　てきとう　やさしい　おまいり",
    addressSource: "45rzkUq8tNAhVn45Xh83qWH4XMqPzwpdoD2nzV6Ro6bjbFKcG778PyycScLcvLUgYnVBx46hZkTAGWrFF32TpFoYFfo8tsQ",
    spendKeySource: "0f36c650456f1139d12d54ac60d377992a320788a18ae046b8aed1b9f1160006",
  ),
  PolyseedTestCase(
    language: PolyseedLanguage.korean,
    polyseedSource: "월세 결국 암컷 외침 장인 적성 어쩐지 방면 코미디 쿠데타 가장 적당히 관계 혹시 기침 선택",
    addressSource: "467kdvyVLWK2VcNVm8B5UTAyMNJDRp2kxi362zpdxjUSAKaqZhpFzwp1V98oYtwbRHCSCfj7LH6wEEWXctgnfS8H9eYRgFX",
    spendKeySource: "0ecb8bb075cbb288a9111046d5178acbe80a2051f3d65f642f50e21a50995c0b",
  ),
  PolyseedTestCase(
    language: PolyseedLanguage.portuguese,
    polyseedSource: "refinar banquete endossar bicudo dueto decalque xarope entrada agachar emulador fraterno triagem incenso expandir estudo mancha",
    addressSource: "46uGxrSaCf6gyHdymRrxfS1si34UXngdojgdiCL3CVqDfxLt54AyvbYSw3C2Fa5SceFFpe7PJRCnuJYzqjZWcszuDQixKU1",
    spendKeySource: "4818f65846f473a76862a32b1adccd9a7465dab54ebf4a8bb0e7d9082d77370f",
  ),
  PolyseedTestCase(
    language: PolyseedLanguage.chineseSimplified,
    polyseedSource: "日 雄 奏 欧 透 绪 手 谈 峡 蒙 财 缆 朝 童 谓 桃",
    addressSource: "49YWMnBVJ3ZA1axRzDStVYKQsNSsNUJ773BcY58uGNrMDRUcpGda9RCVneuJtpTSL2WqN3kazmMVyRs24KN8U7KmCL72c1y",
    spendKeySource: "28405ae092d911b0f2e176f5bf673df5761ca0c6075ece27b50583b0c7d4790d",
  ),
  PolyseedTestCase(
    language: PolyseedLanguage.chineseTraditional,
    polyseedSource: "隱 賴 染 業 農 扎 柄 摸 柯 丹 期 漂 陝 歪 憤 率",
    addressSource: "42npwQ7h3j5j6ExkQXQDeLJNwzYH9MwVjHLYNgGKcXvuXAovQ5bNyk4gZC7jwQMT5VbSsPt7zQyQ393AxZoptmFX3c2osMQ",
    spendKeySource: "3c0e3fa61c570c2a1ecb06f89ce08e88270ac830bc04b66e82ad34d73f0c8f08",
  ),
];

class _PolyseedDartCompatTestDebugState extends State<PolyseedDartCompatTestDebug> {
  String? path;
  
  @override
  void initState() {
    getPolyseedDartTestPath().then((value) {
      setState(() {
        path = value;
      });
    });
    super.initState();
  }

  List<PolyseedTestCase> testCases = [];

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Polyseed dart Compat"),
        ),
        body: const LinearProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polyseed Compat"),
      ),
      body:  SingleChildScrollView(
        child: Column(
          children: [
            (Directory(path!).existsSync()) 
              ? LongOutlinedButton(
                text: "Delete temp dir",
                onPressed: () {
                  Directory(path!).deleteSync(recursive: true);
                  setState(() {
                    
                  });
                },
              ) 
              :  LongOutlinedButton(
                text: "Create wallets",
                onPressed: _createWallets,
              ),
            ..._buildWidgets(testCases),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWidgets(List<PolyseedTestCase> ps) {
    List<Widget> list = [];
for (var i = 0; i < ps.length; i++) {
  final ok = (ps[i].polyseedSource == null || ps[i].polyseedSource == null || ps[i].spendKeySource == null ) ?
               (ps[i].addressDart == ps[i].addressCPP) &&
               (ps[i].spendKeyDart == ps[i].spendKeyDart)
             : (ps[i].addressDart == ps[i].addressCPP) && (ps[i].addressSource == ps[i].addressCPP)  &&
               (ps[i].spendKeyDart == ps[i].spendKeyDart) && (ps[i].spendKeySource == ps[i].spendKeyDart);
  list.add(
    ExpansionTile(
      title: Text( "${ok ? "OK" : "FAIL"}: ${ps[i].language}"),
      subtitle: Text(ps[i].error.join("\n")),
      children: [
        const SelectableText("Polyseed"),
        SelectableText("source: ${ps[i].polyseedSource}"),
        SelectableText("dart: ${ps[i].polyseedDart}"),
        SelectableText("cpp: ${ps[i].polyseedCPP}"),
        const SelectableText("Mnemonic (legacy)"),
        SelectableText("dart: ${ps[i].mnemonicDart}"),
        SelectableText("cpp: ${ps[i].mnemonicCPP}"),
        const SelectableText("Address"),
        SelectableText("source: ${ps[i].addressSource}"),
        SelectableText("dart: ${ps[i].addressDart}"),
        SelectableText("cpp: ${ps[i].addressCPP}"),
        const SelectableText("Spend key"),
        SelectableText("source: ${ps[i].spendKeySource}"),
        SelectableText("dart: ${ps[i].spendKeyDart}"),
        SelectableText("cpp: ${ps[i].spendKeyCPP}"),
      ],
    ),
  );
}
    return list;
  }

  String getLanguageStr(PolyseedLanguage lang) {
    return switch (lang) {
      PolyseedLanguage.czech => "Czech",
      PolyseedLanguage.english => "English",
      PolyseedLanguage.spanish => "Spanish",
      PolyseedLanguage.french => "French",
      PolyseedLanguage.italian => "Italian",
      PolyseedLanguage.japanese => "Japanese",
      PolyseedLanguage.korean => "Korean",
      PolyseedLanguage.portuguese => "Portuguese",
      PolyseedLanguage.chineseSimplified => "Chinese (Simplified)",
      PolyseedLanguage.chineseTraditional => "Chinese (Traditional)",
    };
  }


  PolyseedLang getLanguageDart(PolyseedLanguage lang) {
    return PolyseedLang.getByEnglishName(getLanguageStr(lang));
  }


  Future<void> _createWallets() async {
    Directory(path!).createSync();
     var cases = defaultTestCases;
    for (var lang in PolyseedLanguage.values) {
      var testCase = cases.firstWhere((element) => element.language == lang, orElse: () => PolyseedTestCase(language: lang)); 
      // testCase.polyseedSource ??= monero.Wallet_createPolyseed(language: getLanguageStr(lang));
      testCase.polyseedSource ??= Polyseed.create().encode(getLanguageDart(lang), PolyseedCoin.POLYSEED_MONERO);
      // dart
      Polyseed? dartPolyseed;
      try {
        dartPolyseed = Polyseed.decode(testCase.polyseedSource!, getLanguageDart(lang), PolyseedCoin.POLYSEED_MONERO);
      } catch (e) {
        testCase.error = [...testCase.error, e.toString()];
      }
      final dartw = monero.WalletManager_createDeterministicWalletFromSpendKey(
        wmPtr,
        path: "${path!}/monero_wallet-${DateTime.now().microsecondsSinceEpoch}",
        password: "p",
        language: getLanguageStr(lang),
        spendKeyString: dartPolyseed?.generateKey(PolyseedCoin.POLYSEED_MONERO, 32).toHexString() ?? "null",
        newWallet: true, // TODO(mrcyjanek): safe to remove
        restoreHeight: 0,
      );
      var status = monero.Wallet_status(dartw);
      if (status != 0) {
        testCase.error = [...testCase.error, "Failed to WalletManager_createDeterministicWalletFromSpendKey: ${monero.Wallet_errorString(dartw)}"];
      }
      testCase.polyseedDart = dartPolyseed?.encode(getLanguageDart(lang), PolyseedCoin.POLYSEED_MONERO);
      testCase.mnemonicDart = monero.Wallet_seed(dartw, seedOffset: '');
      testCase.addressDart = monero.Wallet_address(dartw);
      testCase.spendKeyDart = monero.Wallet_secretSpendKey(dartw);

      // cpp
      final cppw = monero.WalletManager_createWalletFromPolyseed(
        wmPtr,
        path: "${path!}/monero_wallet-${DateTime.now().microsecondsSinceEpoch}",
        password: "p",
        mnemonic: testCase.polyseedSource!,
        seedOffset: '',
        newWallet: true,
        restoreHeight: 0,
        kdfRounds: 1,
      );
      status = monero.Wallet_status(cppw);
      if (status != 0) {
        testCase.error = [...testCase.error, "Failed to WalletManager_createWalletFromPolyseed: ${monero.Wallet_errorString(cppw)}"];
      }
      testCase.polyseedCPP = monero.Wallet_getPolyseed(cppw, passphrase: '');
      testCase.mnemonicCPP = monero.Wallet_seed(cppw, seedOffset: '');
      testCase.addressCPP = monero.Wallet_address(cppw);
      testCase.spendKeyCPP = monero.Wallet_secretSpendKey(cppw);
      setState(() {
        testCases.add(testCase);
      });
    }
  }
}
