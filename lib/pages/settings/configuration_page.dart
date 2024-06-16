import 'package:flutter/material.dart';
import 'package:xmruw/pages/config/base.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ConfigurationPage();
      },
    ));
  }

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuration"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ConfigElement(
              text: "disableProxy",
              description:
                  "Disable proxy (recommended when using clearnet node). By default xmruw knows when to disable the proxy, so this option shouldn't be needed unless you are porting to a new operating system and some undefined behaviour happens.",
              onClick: () {
                config.disableProxy = !config.disableProxy;
                config.save();
                setState(() {});
              },
              value: config.disableProxy,
            ),
            ConfigElement(
              text: "enableOpenAlias",
              description:
                  "You can send transactions directly to OpenAlias addresses. If you don't wish to use this option feel free to disable this element.",
              onClick: () {
                config.enableOpenAlias = !config.enableOpenAlias;
                config.save();
                setState(() {});
              },
              value: config.enableOpenAlias,
            ),
            ConfigElement(
              text: "enableAutoLock",
              description:
                  "Automatically lock the wallet after fixed amount of time. Shouldn't be used with PoS mode enabled. Requires enableBackgroundSync",
              onClick: () {
                config.enableAutoLock = !config.enableAutoLock;
                config.save();
                setState(() {});
              },
              value: config.enableAutoLock,
            ),
            ConfigElement(
              text: "enableBackgroundSync",
              description:
                  "Enable background sync patch to sync your wallet when it is left alone without storing private key in memory.",
              onClick: () {
                config.enableBackgroundSync = !config.enableBackgroundSync;
                config.save();
                setState(() {});
              },
              value: config.enableBackgroundSync,
            ),
            ConfigElement(
              text: "enableBuiltInTor",
              description:
                  "On some platforms built-in tor is supported. Whenever there will be a need to talk to a onion service xmruw will start tor proxy if provided proxy details are not working. It is recommended to keep this on for good UX.",
              onClick: () {
                config.enableBuiltInTor = !config.enableBuiltInTor;
                config.save();
                setState(() {});
              },
              value: config.enableBuiltInTor,
            ),
            ConfigElement(
              text: "routeClearnetThruTor",
              description:
                  "If you want you can rounte clearnet traffic over tor, this will hide node connection from ISP but will show that you are using tor. It is not recommended to keep this on, if you want to stay anonymous use Tor nodes.",
              onClick: () {
                config.routeClearnetThruTor = !config.routeClearnetThruTor;
                config.save();
                setState(() {});
              },
              value: config.routeClearnetThruTor,
            ),
            ConfigElement(
              text: "printStarts",
              description:
                  "print() all starts of function calls. Check this if the wallet is crashing and you don't know why, even in release mode last line will tell you which function is causing the crash. NOTE: huge logs will be produced. Use only when needed.",
              onClick: () {
                config.printStarts = !config.printStarts;
                config.save();
                setState(() {});
              },
              value: config.printStarts,
            ),
            ConfigElement(
              text: "showPerformanceOverlay",
              description:
                  "Enables Flutter's built-in overlay that shows time to render a frame.",
              onClick: () {
                config.showPerformanceOverlay = !config.showPerformanceOverlay;
                config.save();
                setState(() {});
              },
              value: config.showPerformanceOverlay,
            ),
            ConfigElement(
              text: "experimentalAccounts",
              description: "Enables experimental multi-account support.",
              onClick: () {
                config.experimentalAccounts = !config.experimentalAccounts;
                config.save();
                setState(() {});
              },
              value: config.experimentalAccounts,
            ),
            ConfigElement(
              text: "enableExperiments",
              description:
                  "Do you want to access the debug menu from settings? You probably don't need to but there is some fun stuff inside.",
              onClick: () {
                config.enableExperiments = !config.enableExperiments;
                config.save();
                setState(() {});
              },
              value: config.enableExperiments,
            ),
            ConfigElement(
              text: "customThemeEnabled",
              description:
                  "If you don't like the built-in theme you can make your own. p.s. if you make a nice one come to our chat group and let me know, I'd love to enable it in wallet.",
              onClick: () {
                config.customThemeEnabled = !config.customThemeEnabled;
                config.save();
                setState(() {});
              },
              value: config.customThemeEnabled,
            ),
            ConfigElement(
              text: "forceEnableScanner",
              description:
                  "Scanner is enabled only on iOS and Android. You can force it's behaviour here.",
              onClick: () {
                config.forceEnableScanner = !config.forceEnableScanner;
                config.save();
                setState(() {});
              },
              value: config.forceEnableScanner,
            ),
            ConfigElement(
              text: "forceEnableText",
              description:
                  "Text is enabled for platforms that do not support scanning. You can force it's behaviour here.",
              onClick: () {
                config.forceEnableText = !config.forceEnableText;
                config.save();
                setState(() {});
              },
              value: config.forceEnableText,
            ),
            ConfigElement(
              text: "enableGraphs",
              description: "[WIP] Spending graphs",
              onClick: () {
                config.enableGraphs = !config.enableGraphs;
                config.save();
                setState(() {});
              },
              value: config.enableGraphs,
            ),
            ConfigElement(
              text: "enablePoS",
              description: "[WIP] Enables experimental PoS mode",
              onClick: () {
                config.enablePoS = !config.enablePoS;
                config.save();
                setState(() {});
              },
              value: config.enablePoS,
            ),
            ConfigElement(
              text: "autoSave",
              description: "Enable background store() calls",
              onClick: () {
                config.autoSave = !config.autoSave;
                config.save();
                setState(() {});
              },
              value: config.autoSave,
            ),
            ConfigElement(
              text: "showExtraOptions",
              description: "Show extra options that may not work",
              onClick: () {
                config.showExtraOptions = !config.showExtraOptions;
                config.save();
                setState(() {});
              },
              value: config.showExtraOptions,
            ),
            ConfigElement(
              text: "Enable anonymous online services",
              description:
                  "Query data such as node list, prices and other static data from xmruw.net",
              onClick: () {
                config.enableStaticOnlineServices =
                    !config.enableStaticOnlineServices;
                config.save();
                setState(() {});
              },
              value: config.enableStaticOnlineServices,
            ),
            ConfigElement(
              text: "Online services over tor",
              description:
                  "When downloading static data from xmruw.net use Tor proxy.",
              onClick: () {
                config.staticOnlineServicesOverTor =
                    !config.staticOnlineServicesOverTor;
                config.save();
                setState(() {});
              },
              value: config.staticOnlineServicesOverTor,
            ),
            ConfigElement(
              text: "Enable Device Preview",
              description: "Useful for UI preview",
              onClick: () {
                config.enableDevicePreview = !config.enableDevicePreview;
                config.save();
                setState(() {});
              },
              value: config.enableDevicePreview,
            ),
          ],
        ),
      ),
    );
  }
}

class ConfigElement extends StatefulWidget {
  const ConfigElement({
    super.key,
    required this.text,
    required this.description,
    required this.onClick,
    required this.value,
  });
  final String text;
  final String description;
  final void Function() onClick;
  final bool value;
  @override
  _ConfigElementState createState() => _ConfigElementState();
}

class _ConfigElementState extends State<ConfigElement> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        title: Text(widget.text),
        subtitle: Text(widget.description),
        value: widget.value,
        onChanged: (_) {
          widget.onClick();
        },
      ),
    );
  }
}
