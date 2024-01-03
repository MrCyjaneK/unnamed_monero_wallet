import 'package:anonero/pages/pin_screen.dart';
import 'package:anonero/pages/settings/add_node_screen.dart';
import 'package:anonero/pages/wallet/settings_page.dart';
import 'package:anonero/tools/node.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

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
            },
            child: const Text("Add Node"),
          )
        ],
      ),
      body: Column(
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
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
      child: InkWell(
        onTap: disabled ? null : () => _showDetails(context),
        child: Card(
          child: ListTile(
            title: Text(widget.node.address),
            trailing: IconButton(
              onPressed: disabled ? null : _delete,
              icon: const Icon(Icons.delete),
            ),
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

class _NodeStatusCardState extends State<NodeStatusCard> {
  int height = 0;
  int status = 1;
  String error = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      height = MONERO_Wallet_daemonBlockChainHeight_cached(walletPtr!);
      status = MONERO_Wallet_status(walletPtr!);
      if (status != 0) {
        error = MONERO_Wallet_errorString(walletPtr!);
      }
    });
  }

  Color? _getColor() {
    if (status != 0) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    return null;
  }

  String _statusText() {
    if (status == 0) return "Daemon Height: $height";
    if (error == "") return "Unknown error";
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 120,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
          color: _getColor(),
          child: Center(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.node.address,
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
