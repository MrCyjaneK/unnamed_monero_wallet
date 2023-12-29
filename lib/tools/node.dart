import 'dart:convert';
import 'dart:io';

import 'package:anonero/tools/dirs.dart';
import 'package:mutex/mutex.dart';

enum NodeNetwork { clearnet, onion, i2p }

class Node {
  Node({
    required this.address,
    required this.username,
    required this.password,
    required this.id,
  });
  final String address;
  final String username;
  final String password;
  final int id;
  NodeNetwork get network => NodeNetwork.clearnet;

  Map<String, dynamic> toJson() {
    return {
      "_v": 0,
      "id": id,
      "address": address,
      "username": username,
      "password": password,
    };
  }

  Node.fromJson(Map<String, dynamic> json)
      : address = json['address'] as String,
        username = json['username'] as String,
        password = json['password'] as String,
        id = json['id'] as int;
}

final _nodeMutex = Mutex();

class NodeStore {
  NodeStore({
    required this.nodes,
    required this.currentNode,
  });
  final List<Node> nodes;
  int currentNode;
  Map<String, dynamic> toJson() {
    return {
      "_v": 0,
      "nodes": nodes,
      "currentNode": currentNode,
    };
  }

  NodeStore.fromJson(Map<String, dynamic> json)
      : nodes = (json['nodes'] as List<dynamic>)
            .map((e) => Node.fromJson(e as Map<String, dynamic>))
            .toList(),
        currentNode = json['currentNode'] as int;

  static void removeNode(int delId) async {
    await _nodeMutex.acquire();
    final path = await getNodeStore();
    final file = File(path);
    if (!file.existsSync()) {
      file.writeAsStringSync(
          json.encode(NodeStore(nodes: [], currentNode: -1)));
    }
    final ns = NodeStore.fromJson(jsonDecode(file.readAsStringSync()));
    ns.nodes.removeWhere((element) => element.id == delId);
    file.writeAsStringSync(json.encode(ns));
    _nodeMutex.release();
  }

  static Future<NodeStore> getNodes() async {
    await _nodeMutex.acquire();
    final path = await getNodeStore();
    final file = File(path);
    if (!file.existsSync()) {
      file.writeAsStringSync(
          json.encode(NodeStore(nodes: [], currentNode: -1)));
    }
    _nodeMutex.release();
    return NodeStore.fromJson(jsonDecode(file.readAsStringSync()));
  }

  static Future<Node?> getCurrentNode() async {
    await _nodeMutex.acquire();
    final path = await getNodeStore();
    final file = File(path);
    if (!file.existsSync()) {
      file.writeAsStringSync(
          json.encode(NodeStore(nodes: [], currentNode: -1)));
    }
    final ns = NodeStore.fromJson(jsonDecode(file.readAsStringSync()));
    Node? node;
    for (var n in ns.nodes) {
      if (n.id == ns.currentNode) {
        node = n;
        break;
      }
    }
    _nodeMutex.release();
    return node;
  }

  static int getUniqueId() => DateTime.now().millisecondsSinceEpoch;

  static Future<void> saveNode(Node node, {required bool current}) async {
    final ns = await getNodes();
    final path = await getNodeStore();
    final file = File(path);

    await _nodeMutex.acquire();
    ns.nodes.removeWhere((element) => element.id == node.id);
    if (current) {
      ns.currentNode = node.id;
    }
    ns.nodes.add(node);
    file.writeAsStringSync(json.encode(ns));
    _nodeMutex.release();
  }
}
