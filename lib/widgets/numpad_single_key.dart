import 'package:xmruw/helpers/keyboard.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:flutter/material.dart';

class SingleKey extends StatelessWidget {
  const SingleKey(this.keyId, this.pin, this.callback, {super.key});
  final Keys keyId;
  final PinInput pin;
  final VoidCallback? callback;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                switch (keyId) {
                  case Keys.backspace:
                    if (pin.value.isNotEmpty) {
                      pin.value = pin.value.substring(0, pin.value.length - 1);
                    }
                    break;
                  case Keys.next:
                    break;
                  default:
                    pin.value = "${pin.value}${getKeysChar(keyId)}";
                }
                callback?.call();
              },
              child: Center(
                child: getKeyWidgetPinPad(keyId),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
