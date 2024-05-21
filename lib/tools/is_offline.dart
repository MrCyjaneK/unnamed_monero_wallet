import 'package:xmruw/tools/node.dart';

bool isOffline = false;

Future<void> isOfflineRefresh() async {
  isOffline = (await NodeStore.getCurrentNode()) == null;
}
