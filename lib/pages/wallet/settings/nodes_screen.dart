import 'package:anonero/pages/pin_screen.dart';
import 'package:anonero/pages/wallet/settings/add_node_screen.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:flutter/material.dart';

class NodesScreen extends StatelessWidget {
  const NodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nodes",
        ),
        actions: [
          TextButton(
            onPressed: () => AddNodeScreen.push(context),
            child: const Text("Add Node"),
          )
        ],
      ),
      body: const Column(
        children: [
          NodeStatusCard(),
          Divider(),
          SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
              child: Text(
                "Available Nodes (p.s. change this to orange from settings?)",
              ),
            ),
          ),
          Divider(),
          SingleNodeWidget(
            address: 'monero.filmweb.pl',
            height: 3014472,
            port: 18081,
            version: 16,
            username: '',
            password: '',
          )
        ],
      ),
    );
  }

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const NodesScreen();
      },
    ));
  }
}

class SingleNodeWidget extends StatelessWidget {
  final String address;
  final int height;
  final int port;
  final int version;
  final String username;
  final String password;

  const SingleNodeWidget({
    super.key,
    required this.address,
    required this.height,
    required this.port,
    required this.version,
    required this.username,
    required this.password,
  });
  void _showDetails(BuildContext c) {
    Alert(
      crossAxisAligment: CrossAxisAlignment.start,
      body: [
        SizedBox(
          width: double.maxFinite,
          child: Text(address),
        ),
        const SizedBox(height: 4),
        Text(
          "$height",
          style: Theme.of(c).textTheme.bodySmall,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(),
        ),
        Row(
          children: [
            const Expanded(child: Text('Port')),
            Text(port.toString())
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(),
        ),
        Row(
          children: [
            const Expanded(child: Text('Version')),
            Text(version.toString())
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(),
        ),
        Row(
          children: [
            const Expanded(child: Text('Username')),
            Text(username),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(),
        ),
        Row(
          children: [
            const Expanded(child: Text('Password')),
            Text(password.isEmpty ? "" : "******")
          ],
        ),
      ],
      cancelable: true,
    ).show(c);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => _showDetails(context),
        child: Card(
          child: ListTile(
            title: Text(address),
            subtitle: Text(
              "Daemon Height: $height",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const IconButton(
              onPressed: null,
              icon: Icon(Icons.delete),
            ),
          ),
        ),
      ),
    );
  }
}

class NodeStatusCard extends StatelessWidget {
  const NodeStatusCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 120,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
          child: Center(
            child: ListTile(
              title: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "node.address.onion",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              subtitle: Text(
                "Daemon Height: 3014472",
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
