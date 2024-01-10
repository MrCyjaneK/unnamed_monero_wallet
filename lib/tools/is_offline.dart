import 'package:anonero/tools/node.dart';

late bool isOffline;

Future<void> isOfflineRefresh() async {
  isOffline = (await NodeStore.getCurrentNode()) == null;
}
