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
                  "Disable proxy (recommended when using clearnet node)",
              onClick: () {
                config.disableProxy = !config.disableProxy;
                config.save();
                setState(() {});
              },
              value: config.disableProxy,
            ),
            ConfigElement(
              text: "enableOpenAlias",
              description: "",
              onClick: () {
                config.enableOpenAlias = !config.enableOpenAlias;
                config.save();
                setState(() {});
              },
              value: config.enableOpenAlias,
            ),
            ConfigElement(
              text: "enableAutoLock",
              description: "",
              onClick: () {
                config.enableAutoLock = !config.enableAutoLock;
                config.save();
                setState(() {});
              },
              value: config.enableAutoLock,
            ),
            ConfigElement(
              text: "enableBackgroundSync",
              description: "",
              onClick: () {
                config.enableBackgroundSync = !config.enableBackgroundSync;
                config.save();
                setState(() {});
              },
              value: config.enableBackgroundSync,
            ),
            ConfigElement(
              text: "enableBuiltInTor",
              description: "",
              onClick: () {
                config.enableBuiltInTor = !config.enableBuiltInTor;
                config.save();
                setState(() {});
              },
              value: config.enableBuiltInTor,
            ),
            ConfigElement(
              text: "routeClearnetThruTor",
              description: "",
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
                  "NOTE: huge logs will be produced. Use only when needed.",
              onClick: () {
                config.printStarts = !config.printStarts;
                config.save();
                setState(() {});
              },
              value: config.printStarts,
            ),
            ConfigElement(
              text: "showPerformanceOverlay",
              description: "",
              onClick: () {
                config.showPerformanceOverlay = !config.showPerformanceOverlay;
                config.save();
                setState(() {});
              },
              value: config.showPerformanceOverlay,
            ),
            ConfigElement(
              text: "experimentalAccounts",
              description: "",
              onClick: () {
                config.experimentalAccounts = !config.experimentalAccounts;
                config.save();
                setState(() {});
              },
              value: config.experimentalAccounts,
            ),
            ConfigElement(
              text: "enableExperiments",
              description: "",
              onClick: () {
                config.enableExperiments = !config.enableExperiments;
                config.save();
                setState(() {});
              },
              value: config.enableExperiments,
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
