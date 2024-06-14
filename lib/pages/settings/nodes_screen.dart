import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/pages/settings/add_node_screen.dart';
import 'package:xmruw/pages/wallet/settings_page.dart';
import 'package:xmruw/tools/node.dart';
import 'package:xmruw/tools/show_alert.dart';

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
    final headers = {
      'Content-Type': 'application/json',
    };

    const data = '{"jsonrpc":"2.0","id":"0","method":"get_block_count"}';

    final url = Uri.parse('${widget.node.address}/json_rpc');
    try {
      final res = await http.post(url, headers: headers, body: data);
      final jsonData = json.decode(res.body);
      if (!mounted) return;
      setState(() {
        status = res.statusCode;
        height = jsonData["result"]["count"];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        status = 500;
        error = e.toString();
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
