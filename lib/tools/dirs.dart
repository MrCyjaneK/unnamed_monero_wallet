import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Directory> getWd() async {
  return await getApplicationDocumentsDirectory();
}

Future<String> getMainWalletPath() async {
  return "${(await getWd()).path}/main_wallet";
}

Future<String> getNodeStore() async {
  return "${(await getWd()).path}/nodes.json";
}

Future<String> getProxyStore() async {
  return "${(await getWd()).path}/proxy.json";
}

Future<String> getMaterial3FlagFile() async {
  return "${(await getWd()).path}/material3-flag";
}

Future<String> getPerformanceStoreFile() async {
  return "${(await getWd()).path}/perfmon.json";
}

Future<String> getShowPerformanceOverlayFlagFile() async {
  return "${(await getWd()).path}/performance-overlay-flag";
}

Future<String> getMoneroLogPath() async {
  return "${(await getWd()).path}/monero.log";
}

Future<String> getMoneroExportKeyImagesPath() async {
  return "${(await getWd()).path}/export_key_images";
}

Future<String> getMoneroSignedTxPath() async {
  return "${(await getWd()).path}/signed_tx";
}
