import 'package:xmruw/const/keyboard.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/widgets/numpad_single_key.dart';
import 'package:flutter/material.dart';

class NumericalKeyboard extends StatelessWidget {
  const NumericalKeyboard(
      {super.key,
      required this.pin,
      required this.rebuild,
      required this.showConfirm,
      required this.nextPage});
  final PinInput pin;
  final VoidCallback rebuild;
  final bool Function() showConfirm;
  final VoidCallback? nextPage;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          const Spacer(),
          SingleKey(Keys.a1, pin, rebuild),
          SingleKey(Keys.a2, pin, rebuild),
          SingleKey(Keys.a3, pin, rebuild),
          const Spacer(),
        ]),
        Row(children: [
          const Spacer(),
          SingleKey(Keys.a4, pin, rebuild),
          SingleKey(Keys.a5, pin, rebuild),
          SingleKey(Keys.a6, pin, rebuild),
          const Spacer(),
        ]),
        Row(children: [
          const Spacer(),
          SingleKey(Keys.a7, pin, rebuild),
          SingleKey(Keys.a8, pin, rebuild),
          SingleKey(Keys.a9, pin, rebuild),
          const Spacer(),
        ]),
        Row(children: [
          const Spacer(),
          SingleKey(Keys.backspace, pin, rebuild),
          SingleKey(Keys.a0, pin, rebuild),
          if (showConfirm()) SingleKey(Keys.next, pin, nextPage),
          Spacer(flex: showConfirm() ? 1 : 3),
        ]),
      ],
    );
  }
}
