import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Directory> getWd() async {
  return await getApplicationDocumentsDirectory();
}

Future<String> getMainWalletPath() async {
  return "${(await getWd()).path}/main_wallet";
}
