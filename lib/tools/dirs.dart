import 'dart:io';

import 'package:path_provider/path_provider.dart';

const dir_prefix = "monero";

Future<Directory> getWd() async {
  if (Platform.isLinux) {
    final dir = Directory("${Platform.environment['HOME']}/.config/xmruw");
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }
  if (Platform.isLinux) {
    final dir =
        Directory("${Platform.environment['HOME']}/.config/xmruw/$dir_prefix");
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }
  final dir = Directory(
      "${(await getApplicationDocumentsDirectory()).path}/.data/xmruw/$dir_prefix");
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir;
}

Future<String> getMainWalletPath() async {
  return "${(await getWd()).path}/main_wallet";
}

Future<String> getPolyseedTestPath() async {
  return "${(await getWd()).path}/polyseed_tests";
}

Future<String> getPolyseedDartTestPath() async {
  return "${(await getWd()).path}/polyseed_tests";
}

Future<String> getNodeStore() async {
  return "${(await getWd()).path}/nodes.json";
}

Future<String> getProxyStore() async {
  return "${(await getWd()).path}/proxy.json";
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

Future<String> getMoneroImportOutputsPath() async {
  return "${(await getWd()).path}/import_outputs";
}

Future<String> getMoneroExportOutputsPath() async {
  return "${(await getWd()).path}/export_outputs";
}

Future<String> getMoneroImportKeyImagesPath() async {
  return "${(await getWd()).path}/import_key_images";
}

Future<String> getMoneroUnsignedTxPath() async {
  return "${(await getWd()).path}/unsigned_tx";
}

Future<String> getMoneroSignedTxPath() async {
  return "${(await getWd()).path}/signed_tx";
}

Future<String> getTempBackupPath() async {
  return "${(await getWd()).path}/backup_test";
}

Future<String> getWalletPointerAddrPath() async {
  return "${(await getWd()).path}/ptr_addr";
}

Future<String> getConfigFile() async {
  return "${(await getWd()).path}/config.json";
}
