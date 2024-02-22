import 'package:flutter/material.dart';
import 'package:xmruw/main_clean.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/config/themes.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});
  static void push(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const ThemeSettingsPage();
      },
    ));
  }

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  var themeValue = config.theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change theme"),
      ),
      body: ListView.builder(
        itemCount: AppThemeEnum.values.length,
        itemBuilder: (context, index) {
          if (AppThemeEnum.values[index] == AppThemeEnum.custom &&
              !config.customThemeEnabled) return null;
          return ListTile(
            title: Text(getThemeName(AppThemeEnum.values[index])),
            leading: Radio<AppThemeEnum>(
              value: AppThemeEnum.values[index],
              groupValue: themeValue,
              onChanged: (AppThemeEnum? value) {
                setState(() {
                  themeValue = value!;
                });
                config.theme = value!;
                MyAppState.setTheme(context, getTheme(value));
                config.save();
              },
            ),
          );
        },
      ),
    );
  }
}
