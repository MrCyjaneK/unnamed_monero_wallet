import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anonero/tools/dirs.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/labeled_text_input.dart';
import 'package:anonero_backup/anonero_backup.dart';
import 'package:archive/archive_io.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class BackupDetails {
  BackupDetails({
    this.walletData,
    this.walletKeysData,
    this.metadata,
  });
  Uint8List? walletData;
  Uint8List? walletKeysData;
  AnonJSON? metadata;

  Future<void> encrypt(BuildContext c, String password) async {
    print("a");
    final ze = ZipFileEncoder();
    print("b");
    final tempPath = await getTempBackupPath();
    ze.create(tempPath);
    print("c");
    File("$tempPath.default").writeAsBytesSync(walletData!);
    await ze.addFile(File("$tempPath.default"), "default");
    print("d");
    File("$tempPath.default.keys").writeAsBytesSync(walletKeysData!);
    await ze.addFile(File("$tempPath.default.keys"), "default.keys");
    print("e");

    final metaJson = utf8.encode(
      const JsonEncoder.withIndent('    ').convert(metadata),
    );
    File("$tempPath.anon.json").writeAsBytesSync(metaJson);
    await ze.addFile(File("$tempPath.anon.json"), "anon.json");

    print("f");
    ze.close();
    print("g");

    await AnoneroBackup().encryptFile(
      seedPassphrase: password,
      inFileName: tempPath,
      outFileName: "$tempPath.enc",
    );
    print("h");
    await CRFileSaver.saveFileWithDialog(
      SaveFileDialogParams(
        sourceFilePath: "$tempPath.enc",
        destinationFileName: "backup_${DateTime.now().toIso8601String()}.anon",
      ),
    );
    print("i");
  }

  static Future<BackupDetails> decrypt(BuildContext c) async {
    final fp = await FilePicker.platform.pickFiles();
    if (fp == null) return BackupDetails();
    final pwdCtrl = TextEditingController();
    // ignore: use_build_context_synchronously
    await Alert(
      singleBody: LabeledTextInput(
        ctrl: pwdCtrl,
        label: "Encryption Password",
      ),
      callbackText: "Continue",
      callback: () => Navigator.of(c).pop(),
    ).show(c);

    await AnoneroBackup().decryptFile(
      seedPassphrase: pwdCtrl.text,
      inFileName: fp.files.single.path!,
      outFileName: "${fp.files.single.path!}.dec",
    );
    final inputStream = InputFileStream('${fp.files.single.path!}.dec');
    // Decode the zip from the InputFileStream. The archive will have the contents of the
    // zip, without having stored the data in memory.
    final archive = ZipDecoder().decodeBuffer(inputStream);
    // For all of the entries in the archive
    final bd = BackupDetails();

    for (var file in archive.files) {
      // If it's a file and not a directory
      if (!file.isFile) continue;
      switch (file.name) {
        case "default":
          bd.walletData = file.content as Uint8List;
        case "default.keys":
          bd.walletKeysData = file.content as Uint8List;
        case "anon.json":
          final c = file.content as Uint8List;
          print(c);
          bd.metadata = AnonJSON.fromJson(
            json.decode(
              utf8.decode(
                c,
              ),
            ),
          );
      }
    }
    return bd;
  }
}

class AnonJSON {
  String? version;
  Backup? backup;

  AnonJSON({this.version, this.backup});

  AnonJSON.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    backup = json['backup'] != null ? Backup.fromJson(json['backup']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version'] = version;
    if (backup != null) {
      data['backup'] = backup!.toJson();
    }
    return data;
  }
}

class Backup {
  Node? node;
  Wallet? wallet;
  Meta? meta;

  Backup({this.node, this.wallet, this.meta});

  Backup.fromJson(Map<String, dynamic> json) {
    node = json['node'] != null ? Node.fromJson(json['node']) : null;
    wallet = json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (node != null) {
      data['node'] = node!.toJson();
    }
    if (wallet != null) {
      data['wallet'] = wallet!.toJson();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class Node {
  String? host;
  String? password;
  String? username;
  int? rpcPort;
  String? networkType;
  bool? isOnion;

  Node(
      {this.host,
      this.password,
      this.username,
      this.rpcPort,
      this.networkType,
      this.isOnion});

  Node.fromJson(Map<String, dynamic> json) {
    host = json['host'];
    password = json['password'];
    username = json['username'];
    rpcPort = json['rpcPort'];
    networkType = json['networkType'];
    isOnion = json['isOnion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['host'] = host;
    data['password'] = password;
    data['username'] = username;
    data['rpcPort'] = rpcPort;
    data['networkType'] = networkType;
    data['isOnion'] = isOnion;
    return data;
  }
}

class Wallet {
  String? address;
  String? seed;
  int? restoreHeight;
  int? balanceAll;
  int? numSubaddresses;
  int? numAccounts;
  bool? isWatchOnly;
  bool? isSynchronized;

  Wallet(
      {this.address,
      this.seed,
      this.restoreHeight,
      this.balanceAll,
      this.numSubaddresses,
      this.numAccounts,
      this.isWatchOnly,
      this.isSynchronized});

  Wallet.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    seed = json['seed'];
    restoreHeight = json['restoreHeight'];
    balanceAll = json['balanceAll'];
    numSubaddresses = json['numSubaddresses'];
    numAccounts = json['numAccounts'];
    isWatchOnly = json['isWatchOnly'];
    isSynchronized = json['isSynchronized'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['seed'] = seed;
    data['restoreHeight'] = restoreHeight;
    data['balanceAll'] = balanceAll;
    data['numSubaddresses'] = numSubaddresses;
    data['numAccounts'] = numAccounts;
    data['isWatchOnly'] = isWatchOnly;
    data['isSynchronized'] = isSynchronized;
    return data;
  }
}

class Meta {
  int? timestamp;
  String? network;

  Meta({this.timestamp, this.network});

  Meta.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    network = json['network'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timestamp'] = timestamp;
    data['network'] = network;
    return data;
  }
}
