import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

late Config config;

class Config {
  static Config load(String confPath) {
    final config = Config(confPath);
    if (config.file.existsSync()) {
      try {
        return Config.fromJson(
            confPath, json.decode(config.file.readAsStringSync()));
      } catch (e) {
        print("Config.load: $e");
      }
    }
    return config;
  }

  Config(
    this.confPath, {
    this.disableProxy = false,
    this.primaryColor = Colors.cyan,
    this.enableOpenAlias = true,
    this.enableAutoLock = false,
    this.enableBackgroundSync = false,
    this.enableBuiltInTor = true,
    this.routeClearnetThruTor = false,
    this.printStarts = false,
    this.showPerformanceOverlay = false,
    this.experimentalAccounts = false,
  });

  final String confPath;
  File get file => File(confPath);

  bool disableProxy;
  Color primaryColor;
  bool enableOpenAlias;
  bool enableAutoLock;
  bool enableBackgroundSync;
  bool enableBuiltInTor;
  bool routeClearnetThruTor;
  bool printStarts;
  bool showPerformanceOverlay;
  bool experimentalAccounts;
  void save() {
    file.writeAsString(json.encode(toJson()));
  }

  static Config fromJson(String confPath, Map<String, dynamic> json) {
    final c = Config(confPath);
    if (json['disableProxy'] is bool) {
      c.disableProxy = json['disableProxy'];
    }
    if (json['enableOpenAlias'] is bool) {
      c.enableOpenAlias = json["enableOpenAlias"];
    }
    if (json['enableAutoLock'] is bool) {
      c.enableAutoLock = json["enableAutoLock"];
    }
    if (json['enableBackgroundSync'] is bool) {
      c.enableBackgroundSync = json["enableBackgroundSync"];
    }
    if (json['enableBuiltInTor'] is bool) {
      c.enableBuiltInTor = json["enableBuiltInTor"];
    }
    if (json['routeClearnetThruTor'] is bool) {
      c.routeClearnetThruTor = json["routeClearnetThruTor"];
    }
    if (json['printStarts'] is bool) {
      c.printStarts = json["printStarts"];
    }
    if (json['showPerformanceOverlay'] is bool) {
      c.showPerformanceOverlay = json["showPerformanceOverlay"];
    }
    if (json['experimentalAccounts'] is bool) {
      c.experimentalAccounts = json["experimentalAccounts"];
    }
    return c;
  }

  Map<String, dynamic> toJson() {
    return {
      "disableProxy": disableProxy,
      "enableOpenAlias": enableOpenAlias,
      "enableAutoLock": enableAutoLock,
      "enableBackgroundSync": enableBackgroundSync,
      "enableBuiltInTor": enableBuiltInTor,
      "routeClearnetThruTor": routeClearnetThruTor,
      "printStarts": printStarts,
      "showPerformanceOverlay": showPerformanceOverlay,
      "experimentalAccounts": experimentalAccounts,
    };
  }
}
