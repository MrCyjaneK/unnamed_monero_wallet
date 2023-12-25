import 'package:anonero/pages/progress_screen.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/normal_keyboard.dart';
import 'package:anonero/widgets/numerical_keyboard.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/material.dart';

// createWallet -> createWalletConfirm -> "wallet"
// /|\                               \__ Doesn't match -> \
//  |                                                      |
//   \____________________________________________________/

enum PinScreenFlag {
  createWallet,
  createWalletConfirm,
  restoreWalletSeed,
  restoreWalletSeedConfirm,
}

class PinScreen extends StatefulWidget {
  const PinScreen({super.key, required this.flag, this.initialPin = ""});

  final PinScreenFlag flag;
  final String initialPin;

  @override
  State<PinScreen> createState() => _PinScreenState();

  static void pushConfirmCreate(BuildContext context, String pin) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PinScreen(
          flag: PinScreenFlag.createWalletConfirm,
          initialPin: pin,
        );
      },
    ));
  }

  static void pushConfirmRestore(BuildContext context, String pin) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PinScreen(
          flag: PinScreenFlag.createWalletConfirm,
          initialPin: pin,
        );
      },
    ));
  }

  static void push(BuildContext context, PinScreenFlag flag) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PinScreen(flag: flag);
      },
    ));
  }
}

class PinInput {
  PinInput({this.value = ""});
  String value;
}

class _PinScreenState extends State<PinScreen> {
  PinInput pin = PinInput();

  void _rebuild() {
    setState(() {});
  }

  void _nextPage() {
    switch (widget.flag) {
      case PinScreenFlag.createWallet:
        PinScreen.pushConfirmCreate(context, pin.value);
      case PinScreenFlag.createWalletConfirm:
        if (pin.value != widget.initialPin) {
          Alert(
            title: "Pins doesn't match. Please try again.",
            callback: () => PinScreen.push(context, PinScreenFlag.createWallet),
          ).show(context);
          return;
        } else {
          ProgressScreen.push(context, ProgressScreenFlag.walletCreation);
        }
      case PinScreenFlag.restoreWalletSeed:
        PinScreen.pushConfirmRestore(context, pin.value);
      case PinScreenFlag.restoreWalletSeedConfirm:
        if (pin.value != widget.initialPin) {
          Alert(
            title: "Pins doesn't match. Please try again.",
            callback: () =>
                PinScreen.push(context, PinScreenFlag.restoreWalletSeed),
          ).show(context);
          return;
        } else {
          ProgressScreen.push(context, ProgressScreenFlag.walletRestore);
        }
    }
  }

  String getInputText() {
    return switch (widget.flag) {
      PinScreenFlag.createWallet ||
      PinScreenFlag.restoreWalletSeed =>
        "Enter your pin",
      PinScreenFlag.createWalletConfirm ||
      PinScreenFlag.restoreWalletSeedConfirm =>
        "Confirm your pin",
    };
  }

  bool isPin = true;
  void _switchKeyboard() {
    setState(() {
      isPin = !isPin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              const SizedBox(width: double.maxFinite),
              SafeArea(
                child: IconButton(
                  onPressed: _switchKeyboard,
                  icon: const Icon(Icons.keyboard),
                ),
              ),
              const Center(
                child: SetupLogo(
                  title: null,
                ),
              ),
            ],
          ),
          Text(getInputText()),
          _printInputCircles(),
          if (isPin)
            NumericalKeyboard(
              pin: pin,
              rebuild: _rebuild,
              showConfirm: _showConfirm,
              nextPage: _nextPage,
            ),
        ],
      ),
      bottomNavigationBar: (!isPin)
          ? NormalKeyboard(
              pin: pin,
              rebuild: _rebuild,
              showConfirm: _showConfirm,
              nextPage: _nextPage,
            )
          : null,
    );
  }

  bool _showConfirm() {
    return pin.value.length >= 4;
  }

  Widget _printInputCircles() {
    var list = <Widget>[];

    for (int i = 0; i < pin.value.length; i++) {
      list.add(const Padding(
        padding: EdgeInsets.all(8.0),
        child: Circle(),
      ));
    }
    if (list.isEmpty) {
      list.add(const Padding(
        padding: EdgeInsets.all(14.0), // +Circle()
      ));
    }
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: list,
      ),
    );
  }
}

class Circle extends StatelessWidget {
  final Color? color;

  const Circle({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final intColor =
        color ?? Theme.of(context).textTheme.bodySmall?.color ?? Colors.white;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: intColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: intColor,
          width: 1,
        ),
      ),
    );
  }
}
