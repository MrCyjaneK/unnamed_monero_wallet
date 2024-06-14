import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:monero/monero.dart' as monero;
import 'package:mutex/mutex.dart';
import 'package:xmruw/helpers/resource.g.dart';
import 'package:xmruw/main_clean.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/pages/settings/add_node_screen.dart';
import 'package:xmruw/pages/settings/configuration_page.dart';
import 'package:xmruw/pages/settings/nodes_screen.dart';
import 'package:xmruw/pages/setup/backup_restore.dart';
import 'package:xmruw/pages/setup/node_connection.dart';
import 'package:xmruw/pages/setup/proxy_settings.dart';
import 'package:xmruw/pages/wallet/wallet_home.dart';
import 'package:xmruw/tools/backup_class.dart';
import 'package:xmruw/tools/can_backup.dart';
import 'package:xmruw/tools/dirs.dart';
import 'package:xmruw/tools/node.dart' as node;
import 'package:xmruw/tools/proxy.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_manager.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_elevated_button.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:xmruw/widgets/numerical_keyboard.dart';
import 'package:xmruw/widgets/setup_logo.dart';

// _restoreWallet -> BuildContext
class AnonFirstRun extends StatefulWidget {
  const AnonFirstRun({super.key});

  @override
  State<AnonFirstRun> createState() => _AnonFirstRunState();
}

enum SetupWalletType {
  undefined,
  normal,
  offline,
  viewOnly,
}

class _AnonFirstRunState extends State<AnonFirstRun> {
  bool finalStepShowOtherOptions = false;
  bool privacyStepShowOtherOptions = false;
  var type = SetupWalletType.undefined;
  final _introKey = GlobalKey<IntroductionScreenState>();
  bool showNodes = false;
  node.Node? currentNode;
  node.NodeStore? ns;
  bool showAdvancedRestore = false;

  bool? restore;

  final seedCtrl = TextEditingController();
  List<String> seed = [];
  final heightCtrl = TextEditingController();
  int? height;
  final passphraseEncryptionCtrl = TextEditingController();

  PinInput pin = PinInput();
  late final tCtrl = TextEditingController(text: pin.value);

  Future<void> reloadNodes() async {
    await node.NodeStore.getCurrentNode().then((value) {
      setState(() {
        currentNode = value;
      });
    });
    await node.NodeStore.getNodes().then((value) {
      setState(() {
        ns = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titlePadding: EdgeInsets.only(top: 64),
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 19.0),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
    );
    return IntroductionScreen(
      key: _introKey,
      pages: [
        PageViewModel(
          title: "Welcome to xmruw!",
          body: "Take look at the setup here or skip and use defaults",
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Privacy",
          bodyWidget: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "For most people defaults are fine, but you may want to adjust them\nYou can always change them in settings",
                  style: pageDecoration.bodyTextStyle,
                ),
                ConfigElement(
                  text: "Enable anonymous online services",
                  description:
                      "Query data such as node list, prices and other static data from xmruw.nettaki  server",
                  onClick: () {
                    config.enableStaticOnlineServices =
                        !config.enableStaticOnlineServices;
                    config.save();
                    setState(() {});
                  },
                  value: config.enableStaticOnlineServices,
                ),
                if (!privacyStepShowOtherOptions)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            privacyStepShowOtherOptions =
                                !privacyStepShowOtherOptions;
                          });
                        },
                        child: const Text("More options"),
                      ),
                    ],
                  ),
                if (privacyStepShowOtherOptions)
                  ConfigElement(
                    text: "Force Tor",
                    description:
                        "Force Tor proxy on clearnet nodes (not recommended)",
                    onClick: () {
                      config.routeClearnetThruTor =
                          !config.routeClearnetThruTor;
                      config.save();
                      setState(() {});
                    },
                    value: config.routeClearnetThruTor,
                  ),
              ],
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Let's start!",
          bodyWidget: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Please select which wallet type do you want to use",
                  style: pageDecoration.bodyTextStyle,
                ),
                const SizedBox(height: 16),
                LongElevatedButton(
                  onPressed: () async {
                    setState(() {
                      type = SetupWalletType.normal;
                    });
                    await Future.delayed(const Duration(milliseconds: 133));
                    _introKey.currentState?.next();
                  },
                  text: "Normal Wallet",
                  backgroundColor: Colors.white,
                ),
                if (!finalStepShowOtherOptions)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            finalStepShowOtherOptions =
                                !finalStepShowOtherOptions;
                          });
                        },
                        child: const Text("Other options"),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (finalStepShowOtherOptions)
                  LongElevatedButton(
                    onPressed: () async {
                      setState(() {
                        type = SetupWalletType.offline;
                      });
                      await Future.delayed(const Duration(milliseconds: 133));
                      _introKey.currentState?.next();
                    },
                    text: "Offline Wallet",
                  ),
                const SizedBox(height: 16),
                if (finalStepShowOtherOptions)
                  LongElevatedButton(
                    onPressed: () async {
                      setState(() {
                        type = SetupWalletType.viewOnly;
                      });
                      await Future.delayed(const Duration(milliseconds: 133));
                      _introKey.currentState?.next();
                    },
                    text: "View-Only Wallet",
                  ),
              ],
            ),
          ),
          decoration: pageDecoration,
        ),
        if ([SetupWalletType.normal, SetupWalletType.viewOnly].contains(type))
          PageViewModel(
            title: "Connection settings",
            bodyWidget: Column(
              children: [
                LongElevatedButton(
                  onPressed: () {
                    ProxySettings.push(context);
                  },
                  text: "Proxy Settings",
                ),
                const SizedBox(height: 16),
                LongElevatedButton(
                  onPressed: () {
                    _introKey.currentState?.next();
                  },
                  text: "Continue",
                  backgroundColor: Colors.white,
                ),
              ],
            ),
            decoration: pageDecoration,
          ),
        if ([SetupWalletType.normal, SetupWalletType.viewOnly].contains(type))
          PageViewModel(
            title: "Select Node",
            bodyWidget: (!showNodes)
                ? LongElevatedButton(
                    onPressed: () async {
                      await reloadNodes();
                      if (ns!.nodes.isEmpty) {
                        final nListStr =
                            (await rootBundle.loadString(R.ASSETS_NODES_TXT))
                                .trim();
                        final nList = nListStr.split("\n");
                        nList.shuffle();
                        for (var n in nList) {
                          await node.NodeStore.saveNode(
                              node.Node(
                                address: n,
                                username: '',
                                password: '',
                                id: node.NodeStore.getUniqueId(),
                              ),
                              current: true);
                        }
                      }
                      await reloadNodes();
                      setState(() {
                        showNodes = !showNodes;
                      });
                    },
                    text: "Show Nodes",
                    backgroundColor: Colors.white,
                  )
                : Column(
                    children: [
                      (currentNode == null)
                          ? const Text("No node")
                          : (node.Node n) {
                              return NodeStatusCard(node: n);
                            }(currentNode!),
                      if (ns != null)
                        ...List.generate(
                          ns!.nodes.length,
                          (index) => SingleNodeWidget(
                            node: ns!.nodes[index],
                            disabled: ns!.nodes[index].id == ns!.currentNode,
                            rebuildParent: () {
                              reloadNodes();
                            },
                          ),
                        ),
                      LongOutlinedButton(
                          onPressed: () async {
                            await AddNodeScreen.push(context);
                            reloadNodes();
                            Future.delayed(const Duration(milliseconds: 222))
                                .then((value) => reloadNodes());
                          },
                          text: "Add Custom Node")
                    ],
                  ),
            decoration: pageDecoration,
          ),
        if ((type == SetupWalletType.normal ||
                type == SetupWalletType.offline) &&
            restore == null)
          PageViewModel(
            title: "What to do?",
            bodyWidget: Column(
              children: [
                LongElevatedButton(
                  onPressed: () {
                    setState(() {
                      restore = false;
                    });
                  },
                  text: "Create New Wallet",
                ),
                const SizedBox(height: 16),
                LongElevatedButton(
                  onPressed: () {
                    setState(() {
                      restore = true;
                    });
                  },
                  text: "Restore Wallet",
                ),
              ],
            ),
            decoration: pageDecoration,
          ),
        if (restore == true)
          PageViewModel(
            title: "Seed information",
            bodyWidget: Column(
              children: [
                LabeledTextInput(
                  label: "",
                  ctrl: seedCtrl,
                  minLines: 8,
                  maxLines: 8,
                  onEdit: () {
                    setState(() {
                      seed = seedCtrl.text.trim().split(" ");
                    });
                  },
                ),
                if (seed.length > 16 + 1)
                  LabeledTextInput(
                    label: "RESTORE HEIGHT",
                    ctrl: heightCtrl,
                    onEdit: () {
                      setState(() {
                        height = int.tryParse(heightCtrl.text.trim());
                      });
                    },
                  ),
                if (!showAdvancedRestore)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showAdvancedRestore = !showAdvancedRestore;
                          });
                          Alert(
                            title:
                                "WARNING\n\nWhile enabling passphrase encryption you need to remember your seed and your passphrase, otherwise you won't be able to restore your wallet.",
                            cancelable: true,
                          ).show(context);
                        },
                        child: const Text("Passphrase encryption"),
                      ),
                    ],
                  ),
                if (showAdvancedRestore)
                  LabeledTextInput(
                      label: "PASSPHRASE ENCRYPTION",
                      ctrl: passphraseEncryptionCtrl),
              ],
            ),
            decoration: pageDecoration,
          ),
        if ((seed.length == 25 && height != null) || (seed.length == 16))
          PageViewModel(
            title: "Wallet Password",
            bodyWidget: Column(
              children: [
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
                  },
                ),
                NumericalKeyboard(
                  pin: pin,
                  rebuild: () {
                    setState(() {});
                    tCtrl.text = pin.value;
                  },
                  showConfirm: _showConfirm,
                  nextPage: () async {
                    _beginRestore();
                    await Future.delayed(const Duration(milliseconds: 133));
                    _introKey.currentState?.next();
                  },
                ),
              ],
            ),
            decoration: pageDecoration,
          ),
        if (didRestoreStart)
          PageViewModel(
            title: "Restoring",
            bodyWidget: Column(
              children: List.generate(
                  progressDisplay.length + (progressFailed ? 1 : 0), (index) {
                if (progressFailed && index == progressDisplay.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Card(
                      child: ListTile(
                        title: const Text("Error"),
                        subtitle: Text(progressFailedReason),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      Text(progressDisplay[index]),
                      const Spacer(),
                      (index + 1 == progressDisplay.length)
                          ? (!progressFailed)
                              ? (progressCompleted)
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : const SizedBox.square(
                                      dimension: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: .75,
                                      ),
                                    )
                              : Icon(
                                  Icons.error_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                )
                          : const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                    ],
                  ),
                );
              }),
            ),
            decoration: pageDecoration,
          ),
        if (progressCompleted)
          PageViewModel(
            title: "Wallet ready!",
            body: "Your wallet is now ready to use!",
            decoration: pageDecoration,
          ),
      ],
      onDone: () => {},
      onSkip: () => {},
      showSkipButton: true,
      showDoneButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }

  final walletMutex = Mutex();
  bool didRestoreStart = false;
  List<String> progressDisplay = [];
  bool progressFailed = false;
  bool progressCompleted = false;
  String progressFailedReason = "";

  void _resetProgress() {
    setState(() {
      progressDisplay = [];
      progressFailed = false;
      progressCompleted = false;
    });
  }

  Future<void> _addProgress(String value) async {
    setState(() {
      progressDisplay.add(value);
    });
    await Future.delayed(const Duration(milliseconds: 333));
  }

  void _failProgress(String error) {
    setState(() {
      progressFailed = true;
      progressFailedReason = error;
    });
  }

  Future<void> _beginRestore() async {
    _resetProgress();
    if (didRestoreStart) {
      await _addProgress("Waiting for wallet file lock");
    }
    setState(() {
      didRestoreStart = true;
    });
    await walletMutex.acquire();
    final walletPath = await getMainWalletPath();
    if (await File(walletPath).exists()) {
      await _addProgress("Deleting old wallet cache");
      await File(walletPath).delete();
    }
    if (await File("$walletPath.keys").exists()) {
      await _addProgress("Deleting old wallet keys");
      await File("$walletPath.keys").delete();
    }
    await _addProgress("Restoring wallet file");
    final offset = passphraseEncryptionCtrl.text.toString();
    final seedStr = seed.join(" ").toString().trim();
    final pinVal = pin.value.toString();
    if (seed.length == 16) {
      final wmPtrAddress = wmPtr.address;
      walletPtr = ffi.Pointer.fromAddress(
        monero.WalletManager_createWalletFromPolyseed(
          ffi.Pointer.fromAddress(wmPtrAddress),
          path: walletPath,
          password: pinVal,
          mnemonic: seedStr,
          seedOffset: passphraseEncryptionCtrl.text,
          newWallet: false,
          restoreHeight: 0,
          kdfRounds: 1,
        ).address,
      );
    } else {
      final wmPtrAddress = wmPtr.address;
      _addProgress("height: $height");
      final returnAddress = monero.WalletManager_recoveryWallet(
        ffi.Pointer.fromAddress(wmPtrAddress),
        path: walletPath,
        password: pinVal,
        mnemonic: seedStr,
        restoreHeight: height!,
        seedOffset: offset,
      ).address;
      walletPtr = ffi.Pointer.fromAddress(returnAddress);
    }
    int status = monero.Wallet_status(walletPtr!);
    if (status != 0) {
      _failProgress(monero.Wallet_errorString(walletPtr!));
      walletMutex.release();
      return;
    }
    await _addProgress("Initializing wallet (offline)");
    final wPtrAddr = walletPtr!.address;
    final n = await node.NodeStore.getCurrentNode();
    monero.Wallet_init(
      ffi.Pointer.fromAddress(wPtrAddr),
      daemonAddress: "",
    );
    status = monero.Wallet_status(walletPtr!);
    if (status != 0) {
      _failProgress(monero.Wallet_errorString(walletPtr!));
      walletMutex.release();
      return;
    }
    await _addProgress("Storing wallet");
    monero.Wallet_store(walletPtr!);
    status = monero.Wallet_status(walletPtr!);
    if (status != 0) {
      _failProgress(monero.Wallet_errorString(walletPtr!));
      walletMutex.release();
      return;
    }

    if (height != null) {
      await _addProgress("Setting refresh height");
      monero.Wallet_setRefreshFromBlockHeight(
        walletPtr!,
        refresh_from_block_height: height!,
      );
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }
      await _addProgress("Triggering rescan");

      monero.Wallet_rescanBlockchainAsync(walletPtr!);
      status = monero.Wallet_status(walletPtr!);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }

      monero.Wallet_refreshAsync(walletPtr!);
      status = monero.Wallet_status(walletPtr!);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }

      monero.Wallet_rescanBlockchainAsync(walletPtr!);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }

      monero.Wallet_refreshAsync(walletPtr!);
      status = monero.Wallet_status(walletPtr!);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }

      await _addProgress("Closing wallet");
      monero.WalletManager_closeWallet(wmPtr, walletPtr!, true);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }

      await _addProgress("Opening wallet");
      walletPtr = monero.WalletManager_openWallet(
        wmPtr,
        path: walletPath,
        password: pinVal,
      );

      await _addProgress("Initializing wallet");
      final wPtrAddr = walletPtr!.address;
      final n = await node.NodeStore.getCurrentNode();
      final ProxyStore proxy = (await ProxyStore.getProxy());

      final proxyAddress = ((n == null || config.disableProxy)
          ? ""
          : proxy.getAddress(n.network));
      print("proxyAddress: $proxyAddress");
      monero.Wallet_init(
        walletPtr!,
        daemonAddress: n?.address ?? "",
        daemonUsername: n?.username ?? "",
        daemonPassword: n?.password ?? "",
        proxyAddress: proxyAddress,
      );
      await _addProgress("Setting refresh height");
      monero.Wallet_setRefreshFromBlockHeight(
        walletPtr!,
        refresh_from_block_height: height!,
      );
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }
      await _addProgress("Triggering rescan");

      monero.Wallet_rescanBlockchainAsync(walletPtr!);
      status = monero.Wallet_status(walletPtr!);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }

      monero.Wallet_refreshAsync(walletPtr!);
      status = monero.Wallet_status(walletPtr!);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }

      monero.Wallet_rescanBlockchainAsync(walletPtr!);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }

      monero.Wallet_refreshAsync(walletPtr!);
      status = monero.Wallet_status(walletPtr!);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }
      monero.Wallet_startRefresh(walletPtr!);
      status = monero.Wallet_status(walletPtr!);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }

      monero.Wallet_refreshAsync(walletPtr!);
      status = monero.Wallet_status(walletPtr!);
      if (status != 0) {
        _failProgress(monero.Wallet_errorString(walletPtr!));
        walletMutex.release();
        return;
      }
    }

    // await _addProgress("Closing wallet");
    // monero.WalletManager_closeWallet(wmPtr, walletPtr!, true);
    // if (status != 0) {
    //   _failProgress(monero.Wallet_errorString(walletPtr!));
    //   walletMutex.release();
    //   return;
    // }
    setState(() {
      progressCompleted = true;
    });
    walletMutex.release();
    Future.delayed(const Duration(milliseconds: 722)).then((value) {
      // PinScreen.pushReplace(
      //   context,
      //   PinScreenFlag.openMainWallet,
      //   passphrase: '',
      // );
      WalletHome.push(context);
    });
  }

  bool _showConfirm() {
    return pin.value.length >= 4;
  }

  void restoreWalletNero(BuildContext c) async {
    await initLocalNodes();
    SetupNodeConnection.push(c, SetupNodeConnectionFlag.restoreWalletNero);
  }

  void restoreWallet(BuildContext c) {
    Alert(
      singleBody: const SetupLogo(
        title: "Restore",
        width: 80,
        fontSize: 18,
      ),
      overrideActions: [
        LongAlertButtonAlt(
          text: "RESTORE FROM BACKUP",
          callback: !canBackup() ? null : () => restoreFromBackup(c),
        ),
        const Divider(),
        LongAlertButtonAlt(
          text: "RESTORE FROM SEED",
          callback: () => restoreFromSeed(c),
        ),
        const SizedBox(height: 16)
      ],
    ).show(c);
  }

  void restoreFromSeed(BuildContext c) {
    Navigator.of(c).pop();
    SetupNodeConnection.push(c, SetupNodeConnectionFlag.restoreWalletSeed);
  }

  void restoreFromBackup(BuildContext c) async {
    Navigator.of(c).pop();
    final bd = await BackupDetails.decrypt(c);
    // ignore: use_build_context_synchronously
    BackupRestorePage.push(c, bd);
  }
}

class SetupOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const SetupOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1.0, color: Colors.white),
              shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 12, color: Colors.white),
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
            ),
            onPressed: onPressed,
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
