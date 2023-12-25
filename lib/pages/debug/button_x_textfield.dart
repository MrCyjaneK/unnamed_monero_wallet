import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class ButtonTextFieldDebug extends StatelessWidget {
  ButtonTextFieldDebug({super.key});

  final teCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Button x TextField"),
      ),
      body: Column(
        children: [
          const Divider(),
          const SelectableText("Exhibit 1. LongOutlinedButton"),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: LongOutlinedButton(text: "THIS IS A BUTTON"),
          ),
          const Divider(),
          const SelectableText("Exhibit 2. LabeledTextInput"),
          LabeledTextInput(label: null, ctrl: teCtrl),
          const Divider(),
          const SelectableText("Exhibit 3. Stack(LOB, LTI)"),
          Stack(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: LongOutlinedButton(text: "THIS IS A BUTTON"),
              ),
              LabeledTextInput(label: null, ctrl: teCtrl),
            ],
          ),
          const Divider(),
          const SelectableText("Exhibit 4. Stack(LTI, LOB)"),
          Stack(
            children: [
              LabeledTextInput(label: null, ctrl: teCtrl),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: LongOutlinedButton(text: "THIS IS A BUTTON"),
              ),
            ],
          ),
          const SelectableText(
            'NOTE: A little padding is applied to make the top of '
            'LTI be the same level as LOB (4px)',
          )
        ],
      ),
    );
  }

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return ButtonTextFieldDebug();
      },
    ));
  }
}
