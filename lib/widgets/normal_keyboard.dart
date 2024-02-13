import 'package:xmruw/const/keyboard.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:flutter/material.dart';

class NormalKeyboard extends StatefulWidget {
  const NormalKeyboard(
      {super.key,
      required this.pin,
      required this.rebuild,
      required this.showConfirm,
      required this.nextPage});
  final PinInput pin;
  final VoidCallback rebuild;
  final bool Function() showConfirm;
  final VoidCallback nextPage;

  @override
  State<NormalKeyboard> createState() => _NormalKeyboardState();
}

class _NormalKeyboardState extends State<NormalKeyboard> {
  bool s = true;

  void _shift() {
    setState(() {
      s = !s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          const Spacer(),
          KbKey(s ? Keys.a1 : Keys.exclamation, widget.pin, widget.rebuild),
          KbKey(s ? Keys.a2 : Keys.at, widget.pin, widget.rebuild),
          KbKey(s ? Keys.a3 : Keys.hash, widget.pin, widget.rebuild),
          KbKey(s ? Keys.a4 : Keys.dollar, widget.pin, widget.rebuild),
          KbKey(s ? Keys.a5 : Keys.percent, widget.pin, widget.rebuild),
          KbKey(s ? Keys.a6 : Keys.caret, widget.pin, widget.rebuild),
          KbKey(s ? Keys.a7 : Keys.ampersand, widget.pin, widget.rebuild),
          KbKey(s ? Keys.a8 : Keys.asterisk, widget.pin, widget.rebuild),
          KbKey(s ? Keys.a9 : Keys.pOpen, widget.pin, widget.rebuild),
          KbKey(s ? Keys.a0 : Keys.pClose, widget.pin, widget.rebuild),
          KbKey(Keys.backspace, widget.pin, widget.rebuild),
          const Spacer(),
        ]),
        Row(children: [
          const Spacer(),
          KbKey(s ? Keys.q : Keys.Q, widget.pin, widget.rebuild),
          KbKey(s ? Keys.w : Keys.W, widget.pin, widget.rebuild),
          KbKey(s ? Keys.e : Keys.E, widget.pin, widget.rebuild),
          KbKey(s ? Keys.r : Keys.R, widget.pin, widget.rebuild),
          KbKey(s ? Keys.t : Keys.T, widget.pin, widget.rebuild),
          KbKey(s ? Keys.y : Keys.Y, widget.pin, widget.rebuild),
          KbKey(s ? Keys.u : Keys.U, widget.pin, widget.rebuild),
          KbKey(s ? Keys.i : Keys.I, widget.pin, widget.rebuild),
          KbKey(s ? Keys.o : Keys.O, widget.pin, widget.rebuild),
          KbKey(s ? Keys.p : Keys.P, widget.pin, widget.rebuild),
          const Spacer(flex: 1),
        ]),
        Row(children: [
          const Spacer(),
          KbKey(s ? Keys.a : Keys.A, widget.pin, widget.rebuild),
          KbKey(s ? Keys.s : Keys.S, widget.pin, widget.rebuild),
          KbKey(s ? Keys.d : Keys.D, widget.pin, widget.rebuild),
          KbKey(s ? Keys.f : Keys.F, widget.pin, widget.rebuild),
          KbKey(s ? Keys.g : Keys.G, widget.pin, widget.rebuild),
          KbKey(s ? Keys.h : Keys.H, widget.pin, widget.rebuild),
          KbKey(s ? Keys.j : Keys.J, widget.pin, widget.rebuild),
          KbKey(s ? Keys.k : Keys.K, widget.pin, widget.rebuild),
          KbKey(s ? Keys.l : Keys.L, widget.pin, widget.rebuild),
          const Spacer(flex: 1),
        ]),
        Row(children: [
          const Spacer(),
          KbKey(Keys.shift, widget.pin, _shift),
          KbKey(s ? Keys.z : Keys.Z, widget.pin, widget.rebuild),
          KbKey(s ? Keys.x : Keys.X, widget.pin, widget.rebuild),
          KbKey(s ? Keys.c : Keys.C, widget.pin, widget.rebuild),
          KbKey(s ? Keys.v : Keys.V, widget.pin, widget.rebuild),
          KbKey(s ? Keys.b : Keys.B, widget.pin, widget.rebuild),
          KbKey(s ? Keys.n : Keys.N, widget.pin, widget.rebuild),
          KbKey(s ? Keys.m : Keys.M, widget.pin, widget.rebuild),
          const Spacer(flex: 1),
        ]),
        Row(children: [
          const Spacer(flex: 3),
          KbKey(Keys.spacebar, widget.pin, widget.rebuild, flex: 6),
          if (widget.showConfirm())
            KbKey(Keys.next, widget.pin, widget.nextPage, flex: 2),
          Spacer(flex: widget.showConfirm() ? 1 : 3),
        ]),
        const SizedBox(height: 16)
      ],
    );
  }
}

class KbKey extends StatefulWidget {
  const KbKey(this.keyId, this.pin, this.callback, {super.key, this.flex = 1});
  final Keys keyId;
  final PinInput pin;
  final VoidCallback callback;
  final int flex;

  @override
  State<KbKey> createState() => _KbKeyState();
}

class _KbKeyState extends State<KbKey> {
  Color? color;
  void onClick() {
    setState(() {
      color = Theme.of(context).colorScheme.primary;
    });
    Future.delayed(const Duration(milliseconds: 222)).then((value) {
      setState(() {
        color = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            onClick();
            switch (widget.keyId) {
              case Keys.backspace:
                if (widget.pin.value.isNotEmpty) {
                  widget.pin.value = widget.pin.value
                      .substring(0, widget.pin.value.length - 1);
                }
                break;
              case Keys.next:
                break;
              default:
                widget.pin.value =
                    "${widget.pin.value}${getKeysChar(widget.keyId)}";
            }
            widget.callback();
          },
          child: Center(
            child: getKeyWidgetKeyboard(widget.keyId, color),
          ),
        ),
      ),
    );
  }
}
