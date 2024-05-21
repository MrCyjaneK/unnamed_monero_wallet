import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:permission_handler/permission_handler.dart';
import 'package:xmruw/legacy.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/debug.dart';
import 'package:xmruw/pages/debug/monero_log_level.dart';
import 'package:xmruw/pages/setup/passphrase_encryption.dart';
import 'package:xmruw/pages/wallet/wallet_home.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/is_offline.dart';
import 'package:xmruw/tools/node.dart';
import 'package:xmruw/tools/proxy.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_lock.dart';
import 'package:xmruw/tools/wallet_manager.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/normal_keyboard.dart';
import 'package:xmruw/widgets/numerical_keyboard.dart';
import 'package:xmruw/widgets/setup_logo.dart';

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

bool isLocked = false;
bool get isLockedMonero => monero.Wallet_isBackgroundSyncing(walletPtr!);

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

  static Future<void> pushConfirmCreate(BuildContext context, String pin,
      {required String passphrase}) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return PinScreen(
          flag: PinScreenFlag.createWalletConfirm,
          initialPin: pin,
          passphrase: passphrase,
        );
      },
    ));
  }

  static Future<void> pushConfirmRestore(BuildContext context, String pin,
      {required String passphrase, RestoreData? restoreData}) {
    return Navigator.of(context).push(MaterialPageRoute(
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

  static Future<void> pushConfirmRestoreNero(BuildContext context, String pin,
      {required String passphrase, RestoreData? restoreData}) {
    return Navigator.of(context).push(MaterialPageRoute(
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

  static void pushReplace(BuildContext context, PinScreenFlag flag,
      {required String passphrase, RestoreData? restoreData}) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return PinScreen(
          flag: flag,
          passphrase: passphrase,
          restoreData: restoreData,
        );
      },
    ));
  }

  static void pushLock(BuildContext context) async {
    isLocked = true;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const PinScreen(
          flag: PinScreenFlag.backgroundSyncLock,
          passphrase: null,
          restoreData: null,
        );
      },
    ));
    isLocked = false;
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

    setState(() {
      if (pin.value != tCtrl.text) {
        setState(() {
          tCtrl.text = pin.value;
        });
      }
    });
  }

  Future<bool> _createWallet() async {
    final polyseed = monero.Wallet_createPolyseed();
    walletPtr = monero.WalletManager_createWalletFromPolyseed(
      wmPtr,
      path: await getMainWalletPath(),
      password: pin.value,
      mnemonic: polyseed,
      seedOffset: widget.passphrase!,
      newWallet: true,
      restoreHeight: 0,
      kdfRounds: 1,
    );
    final status = monero.Wallet_status(walletPtr!);
    if (status == 0) {
      monero.Wallet_store(walletPtr!);
      return true;
    } // All went fine
    if (mounted) {
      Alert(title: monero.Wallet_errorString(walletPtr!), cancelable: true)
          .show(context);
    }
    return false;
  }

  bool canNextPage = true;

  Future<void> _nextPage() async {
    setState(() {
      canNextPage = false;
    });
    switch (widget.flag) {
      case PinScreenFlag.createWallet:
        await PinScreen.pushConfirmCreate(context, pin.value,
            passphrase: widget.passphrase!);
      case PinScreenFlag.createWalletConfirm:
        if (pin.value != widget.initialPin) {
          await Alert(
            title: "Pins doesn't match. Please try again.",
            callback: () => PinScreen.push(context, PinScreenFlag.createWallet,
                passphrase: widget.passphrase!),
          ).show(context);
          return;
        } else {
          final createdOk = await _createWallet();
          if (!mounted) return;
          if (createdOk) {
            await _openMainWallet();
          }
        }
      case PinScreenFlag.restoreWalletSeed:
        await PinScreen.pushConfirmRestore(context, pin.value,
            passphrase: widget.passphrase!, restoreData: widget.restoreData);
      case PinScreenFlag.restoreWalletSeedConfirm:
        await _restoreWalletSeedConfirm();
      case PinScreenFlag.openMainWallet:
        await _openMainWallet();
      case PinScreenFlag.backgroundSyncLock:
        await _backgroundSyncUnlock();
      case PinScreenFlag.restoreWalletNero:
        await PinScreen.pushConfirmRestoreNero(context, pin.value,
            passphrase: widget.passphrase!, restoreData: widget.restoreData);
      case PinScreenFlag.restoreWalletNeroConfirm:
        await _restoreWalletNeroConfirm();
    }
    if (!mounted) return;
    setState(() {
      canNextPage = true;
    });
  }

  Future<void> _restoreWalletNeroConfirm() async {
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

    walletPtr = monero.WalletManager_createWalletFromKeys(wmPtr,
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
    final status = monero.Wallet_status(walletPtr!);
    if (status != 0) {
      Alert(
        title: """
Unable to restore wallet.
${monero.Wallet_errorString(walletPtr!)}
restoreHeight: ${widget.restoreData!.restoreHeight!},
addressString: ${widget.restoreData!.primaryAddress!},
viewKeyString: ${widget.restoreData!.privateViewKey!},
""",
        cancelable: true,
      ).show(context);
      return;
    }
    if (widget.restoreData!.restoreHeight != null) {
      monero.Wallet_setRefreshFromBlockHeight(
        walletPtr!,
        refresh_from_block_height: widget.restoreData!.restoreHeight!,
      );
    }
    await _initWallet();
    await isOfflineRefresh();
    if (!mounted) return;
    WalletHome.push(context);
  }

  Future<void> _backgroundSyncUnlock() async {
    setState(() {
      openMainWalletUnlockText = "UNLOCKING...";
    });
    await Future.delayed(const Duration(milliseconds: 90));
    final status = monero.Wallet_stopBackgroundSync(walletPtr!, pin.value);
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
    await WalletHome.push(context);
  }

  Future<void> _restoreWalletSeedConfirm() async {
    if (pin.value != widget.initialPin) {
      await Alert(
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
      walletPtr = monero.WalletManager_createWalletFromPolyseed(
        wmPtr,
        path: await getMainWalletPath(),
        password: pin.value,
        mnemonic: widget.restoreData!.seed,
        seedOffset: widget.passphrase!,
        newWallet: false,
        restoreHeight: 0,
        kdfRounds: 1,
      );
    } else {
      walletPtr = monero.WalletManager_recoveryWallet(
        wmPtr,
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
    final status = monero.Wallet_status(walletPtr!);
    if (status != 0) {
      Alert(
        title:
            "Unable to restore wallet.\n${monero.Wallet_errorString(walletPtr!)}",
        cancelable: true,
      ).show(context);
      return;
    }
    if (widget.restoreData!.restoreHeight != null) {
      monero.Wallet_setRefreshFromBlockHeight(
        walletPtr!,
        refresh_from_block_height: widget.restoreData!.restoreHeight!,
      );
    }
    await _initWallet();
    if (!mounted) return;
    monero.Wallet_store(walletPtr!);
    await WalletHome.push(context);
  }

  Future<void> _initWallet() async {
    final logPath = await getMoneroLogPath();
    final logFile = File(logPath);
    if (logFile.existsSync()) {
      logFile.deleteSync();
    }
    logFile.createSync();
    await runEmbeddedTor();
    final Node? node = (await NodeStore.getCurrentNode());
    final ProxyStore proxy = (await ProxyStore.getProxy());
    monero.WalletManagerFactory_setLogLevel(logLevel);
    final proxyAddress = ((node == null || config.disableProxy)
        ? ""
        : proxy.getAddress(node.network));
    print("proxyAddress: $proxyAddress");
    monero.Wallet_init(
      walletPtr!,
      daemonAddress: node?.address ?? "",
      daemonUsername: node?.username ?? "",
      daemonPassword: node?.password ?? "",
      proxyAddress: proxyAddress,
    );
    File(await getWalletPointerAddrPath()).writeAsString(
      walletPtr!.address.toString(),
    );
    print(const JsonEncoder.withIndent('    ').convert({
      "daemonAddress": node?.address ?? "",
      "daemonUsername": node?.username ?? "",
      "daemonPassword": node?.password ?? "",
      "proxyAddress": proxyAddress
    }));
    monero.WalletManagerFactory_setLogLevel(logLevel);
    monero.Wallet_init3(walletPtr!,
        argv0: "", defaultLogBaseName: "", logPath: logPath, console: false);
    monero.WalletManagerFactory_setLogLevel(logLevel);
    monero.Wallet_startRefresh(walletPtr!);
    monero.Wallet_refreshAsync(walletPtr!);
    tempWalletPassword = pin.value;

    final addr = walletPtr!.address;
    Isolate.run(() {
      if (kDebugMode) {
        print("Skipping enableRefresh on kDebugMode");
        return;
      }
      monero.Wallet_daemonBlockChainHeight_runThread(
          Pointer.fromAddress(addr), 1);
    });
    if (Platform.isAndroid) await Permission.notification.request();
    unawaited(isOfflineRefresh());
    unawaited(showServiceNotification());
    if (config.autoSave) {
      _doAutoSaveStuff();
    }
    initLock();
  }

  Future<void> _openMainWallet() async {
    setState(() {
      openMainWalletUnlockText = "UNLOCKING...";
    });
    monero.WalletManagerFactory_setLogLevel(logLevel);
    walletPtr = monero.WalletManager_openWallet(wmPtr,
        path: await getMainWalletPath(), password: pin.value);
    if (!mounted) return;
    final status = monero.Wallet_status(walletPtr!);
    if (status != 0) {
      Alert(
        title:
            "Unable to unlock wallet.\n${monero.Wallet_errorString(walletPtr!)}",
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

  late final tCtrl = TextEditingController(text: pin.value);

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
          // _printInputCircles(),
          TextField(
            obscureText: true,
            style: const TextStyle(fontSize: 48),
            controller: tCtrl,
            decoration: null,
            textAlign: TextAlign.center,
            onChanged: (value) {
              setState(() {
                pin.value = value;
              });
              _rebuild();
            },
          ),
          if (isPin)
            NumericalKeyboard(
              pin: pin,
              rebuild: _rebuild,
              showConfirm: _showConfirm,
              nextPage: canNextPage ? _nextPage : null,
            ),
        ],
      ),
      bottomNavigationBar: (!isPin)
          ? NormalKeyboard(
              pin: pin,
              rebuild: _rebuild,
              showConfirm: _showConfirm,
              nextPage: canNextPage ? _nextPage : null,
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

void _doAutoSaveStuff() async {
  while (true) {
    await Future.delayed(const Duration(seconds: 15));
    final addr = walletPtr!.address;
    await Isolate.run(() {
      final ret = monero.Wallet_store(Pointer.fromAddress(addr));
      final status = monero.Wallet_status(Pointer.fromAddress(addr));
      final err = monero.Wallet_errorString(Pointer.fromAddress(addr));
      print("storing... ${DateTime.now()} - status: $ret - $status - $err");
    });
  }
}
