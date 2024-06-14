import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xmruw/pages/config/themes.dart';

late Config config;

class Config {
  static Config load(String confPath) {
    final config = Config(confPath);
    if (config.file.existsSync()) {
      try {
        return Config.fromJson(
          confPath,
          json.decode(
            config.file.readAsStringSync(),
          ),
        );
      } catch (e) {
        print("Config.load: $e");
      }
    }
    return config;
  }

  Config(
    this.confPath, {
    this.disableProxy = false,
    this.theme = AppThemeEnum.orange,
    this.enableOpenAlias = true,
    this.enableAutoLock = false,
    this.enableBackgroundSync = false,
    this.enableBuiltInTor = true,
    this.routeClearnetThruTor = false,
    this.printStarts = false,
    this.showPerformanceOverlay = false,
    this.experimentalAccounts = false,
    this.fiatCurrency = "USD",
    this.enableExperiments = false,
    this.lastChangelogVersion = -1,
    this.customThemeEnabled = false,
    this.customThemeBrightness = false,
    this.customThemePrimary = Colors.green,
    this.customThemeSecondary = Colors.green,
    this.customThemeSurface = Colors.green,
    this.customThemeBackground = Colors.green,
    this.customThemeError = Colors.green,
    this.customThemeOnPrimary = Colors.green,
    this.customThemeOnSecondary = Colors.green,
    this.customThemeOnSurface = Colors.green,
    this.customThemeOnBackground = Colors.green,
    this.customThemeOnError = Colors.green,
    this.forceEnableScanner = false,
    this.forceEnableText = false,
    this.enableGraphs = false,
    this.enablePoS = false,
    this.autoSave = true,
    this.showExtraOptions = false,
    this.enableStaticOnlineServices = true,
  });

  final String confPath;
  File get file => File(confPath);

  bool disableProxy;
  AppThemeEnum theme;
  bool enableOpenAlias;
  bool enableAutoLock;
  bool enableBackgroundSync;
  bool enableBuiltInTor;
  bool routeClearnetThruTor;
  bool printStarts;
  bool showPerformanceOverlay;
  bool experimentalAccounts;
  String fiatCurrency;
  bool enableExperiments;
  int lastChangelogVersion;
  // themeConfig
  bool customThemeEnabled;
  Color customThemePrimary;
  Color customThemeSecondary;
  Color customThemeSurface;
  Color customThemeBackground;
  Color customThemeError;
  Color customThemeOnPrimary;
  Color customThemeOnSecondary;
  Color customThemeOnSurface;
  Color customThemeOnBackground;
  Color customThemeOnError;
  bool customThemeBrightness;
  bool forceEnableScanner;
  bool forceEnableText;
  bool enableGraphs;
  bool enablePoS;
  bool autoSave;
  bool showExtraOptions;
  bool enableStaticOnlineServices;

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
    if (json['fiatCurrency'] is String) {
      c.fiatCurrency = json["fiatCurrency"];
    }
    if (json['enableExperiments'] is bool) {
      c.enableExperiments = json["enableExperiments"];
    }
    if (json['theme'] is int) {
      c.theme = AppThemeEnum.values[(json["theme"] as int)];
    }
    if (json['lastChangelogVersion'] is int) {
      c.lastChangelogVersion = json["lastChangelogVersion"];
    }
    if (json['customThemeEnabled'] is bool) {
      c.customThemeEnabled = json["customThemeEnabled"];
    }
    if (json['customThemePrimary'] is int) {
      c.customThemePrimary = Color(json["customThemePrimary"] as int);
    }
    if (json['customThemeSecondary'] is int) {
      c.customThemeSecondary = Color(json["customThemeSecondary"] as int);
    }
    if (json['customThemeSurface'] is int) {
      c.customThemeSurface = Color(json["customThemeSurface"] as int);
    }
    if (json['customThemeBackground'] is int) {
      c.customThemeBackground = Color(json["customThemeBackground"] as int);
    }
    if (json['customThemeError'] is int) {
      c.customThemeError = Color(json["customThemeError"] as int);
    }
    if (json['customThemeOnPrimary'] is int) {
      c.customThemeOnPrimary = Color(json["customThemeOnPrimary"] as int);
    }
    if (json['customThemeOnSecondary'] is int) {
      c.customThemeOnSecondary = Color(json["customThemeOnSecondary"] as int);
    }
    if (json['customThemeOnSurface'] is int) {
      c.customThemeOnSurface = Color(json["customThemeOnSurface"] as int);
    }
    if (json['customThemeOnBackground'] is int) {
      c.customThemeOnBackground = Color(json["customThemeOnBackground"] as int);
    }
    if (json['customThemeOnError'] is int) {
      c.customThemeOnError = Color(json["customThemeOnError"] as int);
    }
    if (json['customThemeBrightness'] is bool) {
      c.customThemeBrightness = json["customThemeBrightness"];
    }
    if (json['forceEnableScanner'] is bool) {
      c.forceEnableScanner = json["forceEnableScanner"];
    }
    if (json['forceEnableText'] is bool) {
      c.forceEnableText = json["forceEnableText"];
    }
    if (json['enableGraphs'] is bool) {
      c.enableGraphs = json["enableGraphs"];
    }
    if (json['enablePoS'] is bool) {
      c.enablePoS = json["enablePoS"];
    }
    if (json['autoSave'] is bool) {
      c.autoSave = json["autoSave"];
    }
    if (json['showExtraOptions'] is bool) {
      c.showExtraOptions = json["showExtraOptions"];
    }
    if (json['enableStaticOnlineServices'] is bool) {
      c.enableStaticOnlineServices = json['enableStaticOnlineServices'];
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
      "fiatCurrency": fiatCurrency,
      "enableExperiments": enableExperiments,
      "theme": theme.index,
      "lastChangelogVersion": lastChangelogVersion,
      "customThemeEnabled": customThemeEnabled,
      "customThemePrimary": customThemePrimary.value,
      "customThemeSecondary": customThemeSecondary.value,
      "customThemeSurface": customThemeSurface.value,
      "customThemeBackground": customThemeBackground.value,
      "customThemeError": customThemeError.value,
      "customThemeOnPrimary": customThemeOnPrimary.value,
      "customThemeOnSecondary": customThemeOnSecondary.value,
      "customThemeOnSurface": customThemeOnSurface.value,
      "customThemeOnBackground": customThemeOnBackground.value,
      "customThemeOnError": customThemeOnError.value,
      "customThemeBrightness": customThemeBrightness,
      "forceEnableScanner": forceEnableScanner,
      "enableGraphs": enableGraphs,
      "enablePoS": enablePoS,
      "autoSave": autoSave,
      "showExtraOptions": showExtraOptions,
      "enableStaticOnlineServices": enableStaticOnlineServices,
    };
  }
}
