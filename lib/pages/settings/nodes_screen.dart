import 'dart:ffi';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:monero/monero.dart' as monero;
import 'package:mutex/mutex.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/pages/settings/add_node_screen.dart';
import 'package:xmruw/pages/wallet/settings_page.dart';
import 'package:xmruw/tools/node.dart';
import 'package:xmruw/tools/proxy.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_manager.dart';

class NodesScreen extends StatefulWidget {
  const NodesScreen({super.key});

  @override
  State<NodesScreen> createState() => _NodesScreenState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const NodesScreen();
      },
    ));
  }
}

class _NodesScreenState extends State<NodesScreen> {
  Node? currentNode;
  NodeStore? ns;

  @override
  void initState() {
    reload();
    super.initState();
  }

  void reload() {
    NodeStore.getCurrentNode().then((value) {
      setState(() {
        currentNode = value;
      });
    });
    NodeStore.getNodes().then((value) {
      setState(() {
        ns = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nodes",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await AddNodeScreen.push(context);
              reload();
              Future.delayed(const Duration(milliseconds: 222))
                  .then((value) => reload());
            },
            child: const Text("Add Node"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            (currentNode == null)
                ? const Text("no current node")
                : NodeStatusCard(
                    node: currentNode!,
                  ),
            const Divider(),
            const SizedBox(
              width: double.maxFinite,
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
                child: Text("Available Nodes"),
              ),
            ),
            const Divider(),
            if (ns != null)
              ...List.generate(
                ns!.nodes.length,
                (index) => SingleNodeWidget(
                  node: ns!.nodes[index],
                  disabled: ns!.nodes[index].id == ns!.currentNode,
                  rebuildParent: reload,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SingleNodeWidget extends StatefulWidget {
  final Node node;
  final bool disabled;
  final void Function() rebuildParent;
  const SingleNodeWidget({
    super.key,
    required this.node,
    required this.disabled,
    required this.rebuildParent,
  });

  @override
  State<SingleNodeWidget> createState() => _SingleNodeWidgetState();
}

class _SingleNodeWidgetState extends State<SingleNodeWidget> {
  late bool disabled = widget.disabled;
  void _showDetails(BuildContext c) async {
    await Alert(
      crossAxisAligment: CrossAxisAlignment.start,
      body: [
        SizedBox(
          width: double.maxFinite,
          child: Text(widget.node.address),
        ),
        const SizedBox(height: 4),
        Text(
          r"$height",
          style: Theme.of(c).textTheme.bodySmall,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(),
        ),
        Row(
          children: [
            const Expanded(child: Text('Username')),
            Text(widget.node.username),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(),
        ),
        Row(
          children: [
            const Expanded(child: Text('Password')),
            Text(widget.node.password.isEmpty ? "" : "******")
          ],
        ),
      ],
      cancelable: true,
      callback: _setCurrent,
      callbackText: "Set",
    ).show(c);
    widget.rebuildParent();
  }

  void _setCurrent() async {
    NodeStore.saveNode(widget.node, current: true);
    await setNode(context);
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.rebuildParent();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : () => _showDetails(context),
      child: Card(
        child: ListTile(
          title: Text(
            widget.node.address
                .replaceAll("http://", "")
                .replaceAll("https://", ""),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: disabled ? null : _delete,
            icon: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }

  void _delete() {
    NodeStore.removeNode(widget.node.id);
    setState(() {
      disabled = true;
    });
  }
}

class NodeStatusCard extends StatefulWidget {
  const NodeStatusCard({
    super.key,
    required this.node,
  });

  final Node node;

  @override
  State<NodeStatusCard> createState() => _NodeStatusCardState();
}

final walletManagerNodeMutex = Mutex();

class _NodeStatusCardState extends State<NodeStatusCard> {
  int? height;
  int status = 0;
  String error = '';

  void loadStats() async {
    if (!mounted) return;
    setState(() {
      height = null;
      error = "";
    });
    await walletManagerNodeMutex.acquire();
    final ProxyStore proxy = (await ProxyStore.getProxy());
    final proxyAddress =
        ((config.disableProxy) ? "" : proxy.getAddress(widget.node.network));
    monero.WalletManager_setProxy(wmPtr, proxyAddress);
    monero.WalletManager_setDaemonAddress(wmPtr, widget.node.address);

    final wmPtrAddr = wmPtr.address;
    final remoteHeight = await Isolate.run(() {
      return monero.WalletManager_blockchainHeight(
          Pointer.fromAddress(wmPtrAddr));
    });
    final err = monero.WalletManager_errorString(wmPtr);
    if (!mounted) return;
    if (err != "") {
      setState(() {
        status = 500;
        error = err;
      });
    } else {
      setState(() {
        height = remoteHeight;
        error = "";
        status = 200;
      });
    }
  }

  @override
  void initState() {
    loadStats();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant NodeStatusCard oldWidget) {
    loadStats();
    super.didUpdateWidget(oldWidget);
  }

  Color? _getColor() => switch (status) {
        200 => null,
        _ => Theme.of(context).colorScheme.errorContainer,
      };

  // Color? _getColor()  {
  //   if (status != 200) {
  //     return Theme.of(context).colorScheme.errorContainer;
  //   }
  //   return null;
  // }

  String _statusText() {
    if (status == 200) return "Daemon Height: ${height ?? 'checking...'}";
    if (error == "") return "Unknown error";
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => loadStats(),
      child: SizedBox(
        height: 120,
        child: Card(
          color: _getColor(),
          child: Center(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.node.address
                      .toString()
                      .replaceAll("http://", "")
                      .replaceAll("https://", ""),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              subtitle: Text(
                _statusText(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const Circle(
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
