import 'package:anonero/tools/node.dart';

Future<bool> isOffline() async {
  return (await NodeStore.getCurrentNode()) == null;
}
