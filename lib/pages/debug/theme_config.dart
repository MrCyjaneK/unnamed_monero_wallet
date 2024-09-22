import 'package:flutter/material.dart';
import 'package:xmruw/main_clean.dart';
import 'package:xmruw/pages/config/base.dart';
import 'package:xmruw/pages/config/themes.dart';
import 'package:xmruw/pages/settings/configuration_page.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';

class ThemeConfigPage extends StatefulWidget {
  const ThemeConfigPage({super.key});

  static Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ThemeConfigPage();
      },
    ));
  }

  @override
  State<ThemeConfigPage> createState() => _ThemeConfigPageState();
}

class _ThemeConfigPageState extends State<ThemeConfigPage> {
  //   bool customThemeEnabled;
  final ctrlPrimary = TextEditingController(
      text: config.customThemePrimary.value.toRadixString(16));

  // Color customThemeSecondary;
  final ctrlSecondary = TextEditingController(
      text: config.customThemeSecondary.value.toRadixString(16));

  // Color customThemeSurface;
  final ctrlSurface = TextEditingController(
      text: config.customThemeSurface.value.toRadixString(16));

  // Color customThemeBackground;
  final ctrlBackground = TextEditingController(
      text: config.customThemeBackground.value.toRadixString(16));

  // Color customThemeError;
  final ctrlError = TextEditingController(
      text: config.customThemeError.value.toRadixString(16));

  // Color customThemeOnPrimary;
  final ctrlOnPrimary = TextEditingController(
      text: config.customThemeOnPrimary.value.toRadixString(16));

  // Color customThemeOnSecondary;
  final ctrlOnSecondary = TextEditingController(
      text: config.customThemeOnSecondary.value.toRadixString(16));

  // Color customThemeOnSurface;
  final ctrlOnSurface = TextEditingController(
      text: config.customThemeOnSurface.value.toRadixString(16));

  // Color customThemeOnBackground;
  final ctrlOnBackground = TextEditingController(
      text: config.customThemeOnBackground.value.toRadixString(16));

  // Color customThemeOnError;
  final ctrlOnError = TextEditingController(
      text: config.customThemeOnError.value.toRadixString(16));

  // bool customThemeBrightness;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Theme config"),
        actions: [
          IconButton(
            onPressed: () {
              MyAppState.setTheme(
                context,
                getTheme(AppThemeEnum.custom),
              );
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText("""
Finally all Color objects are encoded using the following format:
#<alpha><rr><gg><bb>
so half-transparent blue would be #070000FF
To get a decent color picker simply search for one in your favourite search engine. In most cases you can grab the hex output and prefix it with FF (for the alpha channel).

At the bottom of the screen you can see ready-made full theme definition. Once the app will look good feel free to send that snippet of code to me (contact details can be found at xmruw.net).

"""
                  .trim()),
            ),
            LabeledTextInput(
              label: "Primary",
              onEdit: () {
                final val = int.tryParse(ctrlPrimary.text, radix: 16);
                if (val == null) return;
                setState(() {
                  config.customThemePrimary = Color(val);
                });
                config.save();
              },
              color: config.customThemePrimary,
              ctrl: ctrlPrimary,
              suffixIcon: IconButton(
                onPressed: () {
                  final val = Color(
                      int.tryParse(ctrlPrimary.text, radix: 16) ?? 0xFF00FFFF);
                  ColorPicker(
                    color: val,
                    onColorChanged: (Color color) {
                      setState(() {
                        config.customThemePrimary = color;
                        ctrlPrimary.text = color.value.toRadixString(16);
                      });
                    },
                  ).showPickerDialog(
                    context,
                  );
                },
                icon: const Icon(Icons.color_lens),
              ),
            ),
            LabeledTextInput(
              label: "Secondary",
              onEdit: () {
                final val = int.tryParse(ctrlSecondary.text, radix: 16);
                if (val == null) return;
                setState(() {
                  config.customThemeSecondary = Color(val);
                });
                config.save();
              },
              color: config.customThemeSecondary,
              ctrl: ctrlSecondary,
              suffixIcon: IconButton(
                onPressed: () {
                  final val = Color(
                      int.tryParse(ctrlSecondary.text, radix: 16) ??
                          0xFF00FFFF);
                  ColorPicker(
                    color: val,
                    onColorChanged: (Color color) {
                      setState(() {
                        config.customThemeSecondary = color;
                        ctrlSecondary.text = color.value.toRadixString(16);
                      });
                    },
                  ).showPickerDialog(
                    context,
                  );
                },
                icon: const Icon(Icons.color_lens),
              ),
            ),
            LabeledTextInput(
              label: "Surface",
              onEdit: () {
                final val = int.tryParse(ctrlSurface.text, radix: 16);
                if (val == null) return;
                setState(() {
                  config.customThemeSurface = Color(val);
                });
                config.save();
              },
              color: config.customThemeSurface,
              ctrl: ctrlSurface,
              suffixIcon: IconButton(
                onPressed: () {
                  final val = Color(
                      int.tryParse(ctrlSurface.text, radix: 16) ?? 0xFF00FFFF);
                  ColorPicker(
                    color: val,
                    onColorChanged: (Color color) {
                      setState(() {
                        config.customThemeSurface = color;
                        ctrlSurface.text = color.value.toRadixString(16);
                      });
                    },
                  ).showPickerDialog(
                    context,
                  );
                },
                icon: const Icon(Icons.color_lens),
              ),
            ),
            LabeledTextInput(
              label: "Background",
              onEdit: () {
                final val = int.tryParse(ctrlBackground.text, radix: 16);
                if (val == null) return;
                setState(() {
                  config.customThemeBackground = Color(val);
                });
                config.save();
              },
              color: config.customThemeBackground,
              ctrl: ctrlBackground,
              suffixIcon: IconButton(
                onPressed: () {
                  final val = Color(
                      int.tryParse(ctrlBackground.text, radix: 16) ??
                          0xFF00FFFF);
                  ColorPicker(
                    color: val,
                    onColorChanged: (Color color) {
                      setState(() {
                        config.customThemeBackground = color;
                        ctrlBackground.text = color.value.toRadixString(16);
                      });
                    },
                  ).showPickerDialog(
                    context,
                  );
                },
                icon: const Icon(Icons.color_lens),
              ),
            ),
            LabeledTextInput(
              label: "Error",
              onEdit: () {
                final val = int.tryParse(ctrlError.text, radix: 16);
                if (val == null) return;
                setState(() {
                  config.customThemeError = Color(val);
                });
                config.save();
              },
              color: config.customThemeError,
              ctrl: ctrlError,
              suffixIcon: IconButton(
                onPressed: () {
                  final val = Color(
                      int.tryParse(ctrlError.text, radix: 16) ?? 0xFF00FFFF);
                  ColorPicker(
                    color: val,
                    onColorChanged: (Color color) {
                      setState(() {
                        config.customThemeError = color;
                        ctrlError.text = color.value.toRadixString(16);
                      });
                    },
                  ).showPickerDialog(
                    context,
                  );
                },
                icon: const Icon(Icons.color_lens),
              ),
            ),
            LabeledTextInput(
              label: "OnPrimary",
              onEdit: () {
                final val = int.tryParse(ctrlOnPrimary.text, radix: 16);
                if (val == null) return;
                setState(() {
                  config.customThemeOnPrimary = Color(val);
                });
                config.save();
              },
              color: config.customThemeOnPrimary,
              ctrl: ctrlOnPrimary,
              suffixIcon: IconButton(
                onPressed: () {
                  final val = Color(
                      int.tryParse(ctrlOnPrimary.text, radix: 16) ??
                          0xFF00FFFF);
                  ColorPicker(
                    color: val,
                    onColorChanged: (Color color) {
                      setState(() {
                        config.customThemeOnPrimary = color;
                        ctrlOnPrimary.text = color.value.toRadixString(16);
                      });
                    },
                  ).showPickerDialog(
                    context,
                  );
                },
                icon: const Icon(Icons.color_lens),
              ),
            ),
            LabeledTextInput(
              label: "OnSecondary",
              onEdit: () {
                final val = int.tryParse(ctrlOnSecondary.text, radix: 16);
                if (val == null) return;
                setState(() {
                  config.customThemeOnSecondary = Color(val);
                });
                config.save();
              },
              color: config.customThemeOnSecondary,
              ctrl: ctrlOnSecondary,
              suffixIcon: IconButton(
                onPressed: () {
                  final val = Color(
                      int.tryParse(ctrlOnSecondary.text, radix: 16) ??
                          0xFF00FFFF);
                  ColorPicker(
                    color: val,
                    onColorChanged: (Color color) {
                      setState(() {
                        config.customThemeOnSecondary = color;
                        ctrlOnSecondary.text = color.value.toRadixString(16);
                      });
                    },
                  ).showPickerDialog(
                    context,
                  );
                },
                icon: const Icon(Icons.color_lens),
              ),
            ),
            LabeledTextInput(
              label: "OnSurface",
              onEdit: () {
                final val = int.tryParse(ctrlOnSurface.text, radix: 16);
                if (val == null) return;
                setState(() {
                  config.customThemeOnSurface = Color(val);
                });
                config.save();
              },
              color: config.customThemeOnSurface,
              ctrl: ctrlOnSurface,
              suffixIcon: IconButton(
                onPressed: () {
                  final val = Color(
                      int.tryParse(ctrlOnSurface.text, radix: 16) ??
                          0xFF00FFFF);
                  ColorPicker(
                    color: val,
                    onColorChanged: (Color color) {
                      setState(() {
                        config.customThemeOnSurface = color;
                        ctrlOnSurface.text = color.value.toRadixString(16);
                      });
                    },
                  ).showPickerDialog(
                    context,
                  );
                },
                icon: const Icon(Icons.color_lens),
              ),
            ),
            LabeledTextInput(
              label: "OnBackground",
              onEdit: () {
                final val = int.tryParse(ctrlOnBackground.text, radix: 16);
                if (val == null) return;
                setState(() {
                  config.customThemeOnBackground = Color(val);
                });
                config.save();
              },
              color: config.customThemeOnBackground,
              ctrl: ctrlOnBackground,
              suffixIcon: IconButton(
                onPressed: () {
                  final val = Color(
                      int.tryParse(ctrlOnBackground.text, radix: 16) ??
                          0xFF00FFFF);
                  ColorPicker(
                    color: val,
                    onColorChanged: (Color color) {
                      setState(() {
                        config.customThemeOnBackground = color;
                        ctrlOnBackground.text = color.value.toRadixString(16);
                      });
                    },
                  ).showPickerDialog(
                    context,
                  );
                },
                icon: const Icon(Icons.color_lens),
              ),
            ),
            LabeledTextInput(
              label: "OnError",
              onEdit: () {
                final val = int.tryParse(ctrlOnError.text, radix: 16);
                if (val == null) return;
                setState(() {
                  config.customThemeOnError = Color(val);
                });
                config.save();
              },
              color: config.customThemeOnError,
              ctrl: ctrlOnError,
              suffixIcon: IconButton(
                onPressed: () {
                  final val = Color(
                      int.tryParse(ctrlOnError.text, radix: 16) ?? 0xFF00FFFF);
                  ColorPicker(
                    color: val,
                    onColorChanged: (Color color) {
                      setState(() {
                        config.customThemeOnError = color;
                        ctrlOnError.text = color.value.toRadixString(16);
                      });
                    },
                  ).showPickerDialog(
                    context,
                  );
                },
                icon: const Icon(Icons.color_lens),
              ),
            ),
            ConfigElement(
              text: "Dark Mode",
              description: "Enable dark mode?",
              onClick: () {
                config.customThemeBrightness = !config.customThemeBrightness;
                config.save();
                setState(() {});
              },
              value: config.customThemeBrightness,
            ),
            const Divider(),
            SelectableText(getConfigText()),
            const Divider(),
            LongOutlinedButton(
              text: "Copy current to custom",
              onPressed: _loadCurrent,
            ),
          ],
        ),
      ),
    );
  }

  void _loadCurrent() {
    config.customThemePrimary = Theme.of(context).colorScheme.primary;
    config.customThemeSecondary = Theme.of(context).colorScheme.secondary;
    config.customThemeSurface = Theme.of(context).colorScheme.surface;
    config.customThemeBackground = Theme.of(context).colorScheme.surface;
    config.customThemeError = Theme.of(context).colorScheme.error;
    config.customThemeOnPrimary = Theme.of(context).colorScheme.onPrimary;
    config.customThemeOnSecondary = Theme.of(context).colorScheme.onSecondary;
    config.customThemeOnSurface = Theme.of(context).colorScheme.onSurface;
    config.customThemeOnBackground = Theme.of(context).colorScheme.onSurface;
    config.customThemeOnError = Theme.of(context).colorScheme.onError;
    config.customThemeBrightness =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    config.save();
    Navigator.of(context).pop();
  }

  String getConfigText() {
    return """
ThemeData(
  fontFamily: 'RobotoMono',
  colorScheme: ColorScheme(
    primary: ${config.customThemePrimary},
    secondary: ${config.customThemeSecondary},
    surface: ${config.customThemeSurface},
    background: ${config.customThemeBackground},
    error: ${config.customThemeError},
    onPrimary: ${config.customThemeOnPrimary},
    onSecondary: ${config.customThemeOnSecondary},
    onSurface: ${config.customThemeOnSurface},
    onBackground: ${config.customThemeOnBackground},
    onError: ${config.customThemeOnError},
    brightness: ${!config.customThemeBrightness ? "Brightness.light" : "Brightness.dark"},
  ),
  useMaterial3: true,
);
    """;
  }
}
