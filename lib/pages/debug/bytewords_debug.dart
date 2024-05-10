import 'dart:typed_data';

import 'package:bytewords/bytewords.dart';
import 'package:flutter/material.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/simple_expansion_tile.dart';

Uint8List input = Uint8List.fromList([0, 1, 2, 128, 255]);
final inputLen = input.length;

class BytewordsDebug extends StatefulWidget {
  const BytewordsDebug({super.key});

  @override
  State<BytewordsDebug> createState() => _BytewordsDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const BytewordsDebug();
      },
    ));
  }
}

const preamble = "Flutter doesn't support FFI tests without heavy workarounding"
    " so I have decided to put the tests here..";

class _BytewordsDebugState extends State<BytewordsDebug> {
  final inputCtrl = TextEditingController(
      text:
          "lpadaocswzcybkpavacahdkkhdwtgtjljtihjpjlcxjlkpjyjokpjycxihksjojljpjyaalstscsdefzbkamlumhesbeynrycmvlsadrdsjepflbcxjtgmfeprytgtkslynsstbawzgrhscegtdenboxdymuprmkgmguclrefsglclplwftaeylngdmnpelkbdamgwuemonnjpkecyvdsbgdmdcnnlkiatqzprcnisjzcxzopreniyhsgecmcshnbzbdbyurjlemchvtselpaoaocswzcybkpavacahdkknltaclsnfhdivwrdmdrpgtoypmhpiokbcegeuejyietktbrdsekilscnwemsgmkttkdrlkteioveisolveehflloolsfaylnrfrycncxmwhlbtcwgrbbmsweytcklnnsrfcwrkmylyhemttkcsvdosaadsbzglwpcpyaeelnuyuezmembdfyehkgotpsclykuymuptnncxgrnsgtsffdpajthypfgalosfbklndimofpcnhdayeyvtzcet");

  Uint8List decoded = Uint8List.fromList([]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bytewords"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SelectableText(preamble),
            SET('test_encode(bw_standard)', () {
              const expectedResult =
                  "able acid also lava zoom jade need echo taxi";
              final result = bytewordsEncode(BytewordsStyle.standard, input);
              if (expectedResult != result) {
                return "invalid encode results";
              }
              return "OK";
            }()),
            SET('test_encode(bw_uri)', () {
              const expectedResult =
                  "able-acid-also-lava-zoom-jade-need-echo-taxi";
              final result = bytewordsEncode(BytewordsStyle.uri, input);
              if (expectedResult != result) {
                return "invalid encode results";
              }
              return "OK";
            }()),
            SET('test_encode(bw_minimal)', () {
              const expectedResult = "aeadaolazmjendeoti";
              final result = bytewordsEncode(BytewordsStyle.minimal, input);
              if (expectedResult != result) {
                return "invalid encode results";
              }
              return "OK";
            }()),
            SET('test_decode(bw_standard)', () {
              final result = bytewordsDecode(BytewordsStyle.standard,
                  "able acid also lava zoom jade need echo taxi");
              if (result.toString() != input.toString()) {
                return "invalid encode results ($result != $input)";
              }
              return "OK";
            }()),
            SET('test_decode(bw_uri)', () {
              final result = bytewordsDecode(BytewordsStyle.uri,
                  "able-acid-also-lava-zoom-jade-need-echo-taxi");
              if (result.toString() != input.toString()) {
                return "invalid encode results ($result != $input)";
              }
              return "OK";
            }()),
            SET('test_decode(bw_minimal)', () {
              final result =
                  bytewordsDecode(BytewordsStyle.minimal, "aeadaolazmjendeoti");
              if (result.toString() != input.toString()) {
                return "invalid encode results ($result != $input)";
              }
              return "OK";
            }()),
            LabeledTextInput(
              label: "Input",
              ctrl: inputCtrl,
              onEdit: () {
                setState(() {
                  decoded =
                      bytewordsDecode(BytewordsStyle.minimal, inputCtrl.text);
                });
              },
            ),
            SelectableText(decoded.toString()),
          ],
        ),
      ),
    );
  }
}
