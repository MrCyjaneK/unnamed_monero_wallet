import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:anonero/main.dart';
import 'package:anonero/pages/debug.dart';
import 'package:anonero/pages/debug/monero_log_level.dart';
import 'package:anonero/pages/setup/passphrase_encryption.dart';
import 'package:anonero/pages/wallet/wallet_home.dart';
import 'package:anonero/tools/dirs.dart';
import 'package:anonero/tools/is_offline.dart';
import 'package:anonero/tools/monero/background_task.dart';
import 'package:anonero/tools/node.dart';
import 'package:anonero/tools/proxy.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:anonero/widgets/normal_keyboard.dart';
import 'package:anonero/widgets/numerical_keyboard.dart';
import 'package:anonero/widgets/setup_logo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

// createWallet -> createWalletConfirm -> "wallet"
// /|\                               \__ Doesn't match -> \
//  |                                                      |
//   \____________________________________________________/
// same foll restore
enum PinScreenFlag {
  createWallet,
  createWalletConfirm,
  restoreWalletSeed,
  restoreWalletNero,
  restoreWalletSeedConfirm,
  restoreWalletNeroConfirm,
  openMainWallet,
  backgroundSyncLock
}

class PinScreen extends StatefulWidget {
  const PinScreen({
    super.key,
    required this.flag,
    this.initialPin = "",
    this.passphrase,
    this.restoreData,
  });

  final RestoreData? restoreData;
  final String? passphrase;

  final PinScreenFlag flag;
  final String initialPin;

  @override
  State<PinScreen> createState() => _PinScreenState();

  static void pushConfirmCreate(BuildContext context, String pin,
      {required String passphrase}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PinScreen(
          flag: PinScreenFlag.createWalletConfirm,
          initialPin: pin,
          passphrase: passphrase,
        );
      },
    ));
  }

  static void pushConfirmRestore(BuildContext context, String pin,
      {required String passphrase, RestoreData? restoreData}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PinScreen(
          flag: PinScreenFlag.restoreWalletSeedConfirm,
          initialPin: pin,
          passphrase: passphrase,
          restoreData: restoreData,
        );
      },
    ));
  }

  static void pushConfirmRestoreNero(BuildContext context, String pin,
      {required String passphrase, RestoreData? restoreData}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PinScreen(
          flag: PinScreenFlag.restoreWalletNeroConfirm,
          initialPin: pin,
          passphrase: passphrase,
          restoreData: restoreData,
        );
      },
    ));
  }

  static void push(BuildContext context, PinScreenFlag flag,
      {required String passphrase, RestoreData? restoreData}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PinScreen(
          flag: flag,
          passphrase: passphrase,
          restoreData: restoreData,
        );
      },
    ));
  }

  static void pushLock(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const PinScreen(
          flag: PinScreenFlag.backgroundSyncLock,
          passphrase: null,
          restoreData: null,
        );
      },
    ));
  }
}

class PinInput {
  PinInput({this.value = ""});
  String value;
}

String tempWalletPassword = "";

class _PinScreenState extends State<PinScreen> {
  PinInput pin = PinInput();

  bool debugPushed = false;

  void _rebuild() {
    if (pin.value == "debug" && !debugPushed) {
      setState(() {
        debugPushed = true;
      });
      DebugPage.push(context);
    }
    setState(() {});
  }

  Future<bool> _createWallet() async {
    final polyseed = MONERO_Wallet_createPolyseed();
    walletPtr = MONERO_WalletManager_createWalletFromPolyseed(
      path: await getMainWalletPath(),
      password: pin.value,
      mnemonic: polyseed,
      seedOffset: widget.passphrase!,
      newWallet: true,
      restoreHeight: 0,
      kdfRounds: 1,
    );
    final status = MONERO_Wallet_status(walletPtr!);
    if (status == 0) return true; // All went fine
    if (mounted) {
      Alert(title: MONERO_Wallet_errorString(walletPtr!), cancelable: true)
          .show(context);
    }
    return false;
  }

  void _nextPage() {
    switch (widget.flag) {
      case PinScreenFlag.createWallet:
        PinScreen.pushConfirmCreate(context, pin.value,
            passphrase: widget.passphrase!);
      case PinScreenFlag.createWalletConfirm:
        if (pin.value != widget.initialPin) {
          Alert(
            title: "Pins doesn't match. Please try again.",
            callback: () => PinScreen.push(context, PinScreenFlag.createWallet,
                passphrase: widget.passphrase!),
          ).show(context);
          return;
        } else {
          _createWallet().then((createdOk) {
            if (!mounted) return;
            if (createdOk) {
              _openMainWallet();
            }
          });
          // ProgressScreen.push(context, ProgressScreenFlag.walletCreation,
          //     passphrase: widget.passphrase);
        }
      case PinScreenFlag.restoreWalletSeed:
        PinScreen.pushConfirmRestore(context, pin.value,
            passphrase: widget.passphrase!, restoreData: widget.restoreData);
      case PinScreenFlag.restoreWalletSeedConfirm:
        _restoreWalletSeedConfirm();
      case PinScreenFlag.openMainWallet:
        _openMainWallet();
      case PinScreenFlag.backgroundSyncLock:
        _backgroundSyncUnlock();
      case PinScreenFlag.restoreWalletNero:
        PinScreen.pushConfirmRestoreNero(context, pin.value,
            passphrase: widget.passphrase!, restoreData: widget.restoreData);
      case PinScreenFlag.restoreWalletNeroConfirm:
        _restoreWalletNeroConfirm();
    }
  }

  void _restoreWalletNeroConfirm() async {
    if (pin.value != widget.initialPin) {
      Alert(
        title: "Pins doesn't match. Please try again.",
        callback: () => PinScreen.push(context, PinScreenFlag.restoreWalletNero,
            passphrase: widget.passphrase!),
      ).show(context);
      return;
    }
    setState(() {
      restoreWalletSeedConfirmText = "RESTORING";
    });

    walletPtr = MONERO_WalletManager_createWalletFromKeys(
        path: await getMainWalletPath(),
        password: pin.value,
        restoreHeight: widget.restoreData!.restoreHeight!,
        addressString: widget.restoreData!.primaryAddress!,
        viewKeyString: widget.restoreData!.privateViewKey!,
        spendKeyString: "",
        nettype: 0);

    setState(() {
      restoreWalletSeedConfirmText = "Confirm your pin";
    });
    if (!mounted) return;
    final status = MONERO_Wallet_status(walletPtr!);
    if (status != 0) {
      Alert(
        title: """
Unable to restore wallet.
${MONERO_Wallet_errorString(walletPtr!)}
restoreHeight: ${widget.restoreData!.restoreHeight!},
addressString: ${widget.restoreData!.primaryAddress!},
viewKeyString: ${widget.restoreData!.privateViewKey!},
""",
        cancelable: true,
      ).show(context);
      return;
    }
    if (widget.restoreData!.restoreHeight != null) {
      MONERO_Wallet_setRefreshFromBlockHeight(
        walletPtr!,
        refresh_from_block_height: widget.restoreData!.restoreHeight!,
      );
    }
    await _initWallet();
    if (!mounted) return;
    WalletHome.push(context);
  }

  void _backgroundSyncUnlock() async {
    setState(() {
      openMainWalletUnlockText = "UNLOCKING...";
    });
    await Future.delayed(const Duration(milliseconds: 90));
    final status = MONERO_Wallet_stopBackgroundSync(walletPtr!, pin.value);
    if (!status) {
      setState(() {
        openMainWalletUnlockText = "UNLOCK: failed";
      });
      return;
    }
    setState(() {
      openMainWalletUnlockText = "UNLOCK: success";
    });
    if (!mounted) return;
    WalletHome.push(context);
  }

  void _restoreWalletSeedConfirm() async {
    if (pin.value != widget.initialPin) {
      Alert(
        title: "Pins doesn't match. Please try again.",
        callback: () => PinScreen.push(context, PinScreenFlag.restoreWalletSeed,
            passphrase: widget.passphrase!),
      ).show(context);
      return;
    }
    setState(() {
      restoreWalletSeedConfirmText = "RESTORING";
    });
    if (widget.restoreData!.restoreHeight == null) {
      walletPtr = MONERO_WalletManager_createWalletFromPolyseed(
        path: await getMainWalletPath(),
        password: pin.value,
        mnemonic: widget.restoreData!.seed,
        seedOffset: widget.passphrase!,
        newWallet: false,
        restoreHeight: 0,
        kdfRounds: 1,
      );
    } else {
      walletPtr = MONERO_WalletManager_recoveryWallet(
        path: await getMainWalletPath(),
        password: pin.value,
        mnemonic: widget.restoreData!.seed,
        restoreHeight: widget.restoreData!.restoreHeight!,
        seedOffset: widget.passphrase!,
      );
    }

    setState(() {
      restoreWalletSeedConfirmText = "Confirm your pin";
    });
    if (!mounted) return;
    final status = MONERO_Wallet_status(walletPtr!);
    if (status != 0) {
      Alert(
        title:
            "Unable to restore wallet.\n${MONERO_Wallet_errorString(walletPtr!)}",
        cancelable: true,
      ).show(context);
      return;
    }
    if (widget.restoreData!.restoreHeight != null) {
      MONERO_Wallet_setRefreshFromBlockHeight(
        walletPtr!,
        refresh_from_block_height: widget.restoreData!.restoreHeight!,
      );
    }
    await _initWallet();
    if (!mounted) return;
    WalletHome.push(context);
  }

  Future<void> _initWallet() async {
    final logPath = await getMoneroLogPath();
    final logFile = File(logPath);
    if (logFile.existsSync()) {
      logFile.deleteSync();
    }
    logFile.createSync();
    final Node? node = (await NodeStore.getCurrentNode());
    final ProxyStore proxy = (await ProxyStore.getProxy());
    MONERO_WalletManagerFactory_setLogLevel(logLevel);
    MONERO_Wallet_init(
      walletPtr!,
      daemonAddress: node?.address ?? "",
      daemonUsername: node?.username ?? "",
      daemonPassword: node?.password ?? "",
      proxyAddress:
          (node == null || disableProxy) ? "" : proxy.getAddress(node.network),
    );
    print(const JsonEncoder.withIndent('    ').convert({
      "daemonAddress": node?.address ?? "",
      "daemonUsername": node?.username ?? "",
      "daemonPassword": node?.password ?? "",
      "proxyAddress":
          (node == null || disableProxy) ? "" : proxy.getAddress(node.network)
    }));
    MONERO_WalletManagerFactory_setLogLevel(logLevel);
    MONERO_Wallet_init3(walletPtr!,
        argv0: "", defaultLogBaseName: "", logPath: logPath, console: false);
    MONERO_WalletManagerFactory_setLogLevel(logLevel);
    MONERO_Wallet_startRefresh(walletPtr!);
    MONERO_Wallet_refreshAsync(walletPtr!);
    tempWalletPassword = pin.value;

    final addr = walletPtr!.address;
    Isolate.run(() {
      if (kDebugMode) {
        print("Skipping enableRefresh on kDebugMode");
        return;
      }
      MONERO_Wallet_daemonBlockChainHeight_runThread(
          Pointer.fromAddress(addr), 1);
    });
    runBackgroundTaskWallet(walletPtr!);
    await isOfflineRefresh();
  }

  void _openMainWallet() async {
    setState(() {
      openMainWalletUnlockText = "UNLOCKING...";
    });
    MONERO_WalletManagerFactory_setLogLevel(logLevel);
    walletPtr = MONERO_WalletManager_openWallet(
        path: await getMainWalletPath(), password: pin.value);
    if (!mounted) return;
    final status = MONERO_Wallet_status(walletPtr!);
    if (status != 0) {
      Alert(
        title:
            "Unable to unlock wallet.\n${MONERO_Wallet_errorString(walletPtr!)}",
        cancelable: true,
      ).show(context);
      setState(() {
        openMainWalletUnlockText = "UNLOCK: failed";
      });
      return;
    }

    setState(() {
      openMainWalletUnlockText = "INITIALIZING...";
    });

    await _initWallet();
    setState(() {
      openMainWalletUnlockText = "UNLOCKED!";
    });
    if (!mounted) return;
    WalletHome.push(context);
  }

  String openMainWalletUnlockText = "Unlock your wallet";
  String restoreWalletSeedConfirmText = "Confirm your pin";
  String getInputText() {
    return switch (widget.flag) {
      PinScreenFlag.createWallet ||
      PinScreenFlag.restoreWalletSeed ||
      PinScreenFlag.restoreWalletNero =>
        "Enter your pin",
      PinScreenFlag.createWalletConfirm => "Confirm your pin",
      PinScreenFlag.restoreWalletSeedConfirm ||
      PinScreenFlag.restoreWalletNeroConfirm =>
        restoreWalletSeedConfirmText,
      PinScreenFlag.openMainWallet => openMainWalletUnlockText,
      PinScreenFlag.backgroundSyncLock => openMainWalletUnlockText,
    };
  }

  bool isPin = true;
  void _switchKeyboard() {
    setState(() {
      isPin = !isPin;
    });
  }

  Widget _debug() {
    return Column(
      children: [
        SelectableText(widget.flag.toString()),
      ],
    );
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
          if (kDebugMode) _debug(),
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
