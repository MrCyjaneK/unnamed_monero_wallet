import 'package:anonero/legacy.dart';
import 'package:anonero/pages/anon/firstrun.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anonero',
      theme: ThemeData(
        fontFamily: 'Monospace',
        colorScheme: colorScheme,
        dividerTheme: const DividerThemeData(
          thickness: 3,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.background, // ?material2 compat
        ),
        dialogBackgroundColor: colorScheme.background, // ?material2 compat
        scaffoldBackgroundColor: colorScheme.background, // material2 compat
        useMaterial3: false,
      ),
      home: const AnonFirstRun(),
    );
  }
}
