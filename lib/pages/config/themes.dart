import 'package:flutter/material.dart';

enum AppThemeEnum {
  red,
  pink,
  purple,
  deepPurple,
  indigo,
  blue,
  lightBlue,
  cyan,
  teal,
  green,
  lightGreen,
  lime,
  yellow,
  amber,
  orange,
  deepOrange,
  brown,
  grey,
  blueGrey,
}

String getThemeName(AppThemeEnum theme) {
  switch (theme) {
    case AppThemeEnum.red:
      return "Crimson Charm";
    case AppThemeEnum.pink:
      return "Blush Blossom";
    case AppThemeEnum.purple:
      return "Royal Velvet";
    case AppThemeEnum.deepPurple:
      return "Midnight Amethyst";
    case AppThemeEnum.indigo:
      return "Azure Twilight";
    case AppThemeEnum.blue:
      return "Sapphire Serenade";
    case AppThemeEnum.lightBlue:
      return "Aqua Breeze";
    case AppThemeEnum.cyan:
      return "Cerulean Dream";
    case AppThemeEnum.teal:
      return "Emerald Isle";
    case AppThemeEnum.green:
      return "Enchanted Forest";
    case AppThemeEnum.lightGreen:
      return "Lime Luster";
    case AppThemeEnum.lime:
      return "Citrus Zest";
    case AppThemeEnum.yellow:
      return "Golden Glow";
    case AppThemeEnum.amber:
      return "Amber Aura";
    case AppThemeEnum.orange:
      return "Tangerine Tango";
    case AppThemeEnum.deepOrange:
      return "Sunset Ember";
    case AppThemeEnum.brown:
      return "Cocoa Essence";
    case AppThemeEnum.grey:
      return "Silver Mist";
    case AppThemeEnum.blueGrey:
      return "Slate Symphony";
  }
}

ThemeData getTheme(AppThemeEnum theme) => switch (theme) {
      AppThemeEnum.red =>
        getMaterialColorSimpleTheme(Colors.red, Brightness.dark),
      AppThemeEnum.pink =>
        getMaterialColorSimpleTheme(Colors.pink, Brightness.dark),
      AppThemeEnum.purple =>
        getMaterialColorSimpleTheme(Colors.purple, Brightness.dark),
      AppThemeEnum.deepPurple =>
        getMaterialColorSimpleTheme(Colors.deepPurple, Brightness.dark),
      AppThemeEnum.indigo =>
        getMaterialColorSimpleTheme(Colors.indigo, Brightness.dark),
      AppThemeEnum.blue =>
        getMaterialColorSimpleTheme(Colors.blue, Brightness.dark),
      AppThemeEnum.lightBlue =>
        getMaterialColorSimpleTheme(Colors.lightBlue, Brightness.dark),
      AppThemeEnum.cyan =>
        getMaterialColorSimpleTheme(Colors.cyan, Brightness.dark),
      AppThemeEnum.teal =>
        getMaterialColorSimpleTheme(Colors.teal, Brightness.dark),
      AppThemeEnum.green =>
        getMaterialColorSimpleTheme(Colors.green, Brightness.dark),
      AppThemeEnum.lightGreen =>
        getMaterialColorSimpleTheme(Colors.lightGreen, Brightness.dark),
      AppThemeEnum.lime =>
        getMaterialColorSimpleTheme(Colors.lime, Brightness.dark),
      AppThemeEnum.yellow =>
        getMaterialColorSimpleTheme(Colors.yellow, Brightness.dark),
      AppThemeEnum.amber =>
        getMaterialColorSimpleTheme(Colors.amber, Brightness.dark),
      AppThemeEnum.orange =>
        getMaterialColorSimpleTheme(Colors.orange, Brightness.dark),
      AppThemeEnum.deepOrange =>
        getMaterialColorSimpleTheme(Colors.deepOrange, Brightness.dark),
      AppThemeEnum.brown =>
        getMaterialColorSimpleTheme(Colors.brown, Brightness.dark),
      AppThemeEnum.grey =>
        getMaterialColorSimpleTheme(Colors.grey, Brightness.dark),
      AppThemeEnum.blueGrey =>
        getMaterialColorSimpleTheme(Colors.blueGrey, Brightness.dark),
    };

ThemeData getMaterialColorSimpleTheme(
    MaterialColor color, Brightness brightness) {
  return ThemeData(
    fontFamily: 'RobotoMono',
    colorScheme:
        ColorScheme.fromSwatch(primarySwatch: color, brightness: brightness),
    dividerTheme: const DividerThemeData(
      thickness: 3,
    ),
    useMaterial3: true,
  );
}
