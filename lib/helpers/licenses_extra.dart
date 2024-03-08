import 'package:xmruw/helpers/licenses.g.dart';

String getLicenseName(String pkg) => switch (pkg) {
      "anonero_backup" => "GPLv3",
      "archive" ||
      "cr_file_saver" ||
      "cupertino_icons" ||
      "dart_pubspec_licenses" ||
      "disable_battery_optimization" ||
      "file_picker" ||
      "flutter_background_service" ||
      "flutter_background_service_android" ||
      "flutter_background_service_ios" ||
      "flutter_background_service_platform_interface" ||
      "flutter_launcher_icons" ||
      "flutter_oss_licenses" ||
      "flutter_svg" ||
      "image" ||
      "math_expressions" ||
      "meta" ||
      "path_parsing" ||
      "permission_handler" ||
      "permission_handler_android" ||
      "permission_handler_apple" ||
      "permission_handler_html" ||
      "permission_handler_platform_interface" ||
      "permission_handler_windows" ||
      "petitparser" ||
      "pointycastle" ||
      "xml" ||
      "yaml" =>
        "MIT",
      "args" ||
      "async" ||
      "boolean_selector" ||
      "characters" ||
      "checked_yaml" ||
      "cli_util" ||
      "collection" ||
      "convert" ||
      "crypto" ||
      "ffi" ||
      "flex_color_picker" ||
      "flex_seed_scheme" ||
      "flutter" ||
      "flutter_lints" ||
      "flutter_local_notifications" ||
      "flutter_local_notifications_linux" ||
      "flutter_local_notifications_platform_interface" ||
      "flutter_plugin_android_lifecycle" ||
      "http" ||
      "http_parser" ||
      "intl" ||
      "js" ||
      "json_annotation" ||
      "leak_tracker" ||
      "leak_tracker_flutter_testing" ||
      "leak_tracker_testing" ||
      "lints" ||
      "matcher" ||
      "mobile_scanner" ||
      "mutex" ||
      "path" ||
      "path_provider" ||
      "path_provider_android" ||
      "path_provider_foundation" ||
      "path_provider_linux" ||
      "path_provider_platform_interface" ||
      "path_provider_windows" ||
      "platform" ||
      "plugin_platform_interface" ||
      "qr" ||
      "qr_flutter" ||
      "source_span" ||
      "stack_trace" ||
      "stream_channel" ||
      "string_scanner" ||
      "term_glpyh" ||
      "test_api" ||
      "timezone" ||
      "tor_binary" ||
      "typed_data" ||
      "vector_graphics" ||
      "vector_graphics_codec" ||
      "vector_graphics_compiler" ||
      "vector_math" ||
      "vm_service" ||
      "web" ||
      "win32" ||
      "xdg_directories" =>
        "BSD-3-Clause",
      "bytewords" ||
      "monero_c" ||
      "offline_market_data" ||
      "unnamed_monero_wallet" =>
        "Proprietary",
      "clock" || "fake_async" || "material_color_utilities" => "Apache-2.0",
      "dbus" => "MPL-2.0",
      "monero" || "libstealth_calculator" => "GPL-3.0",
      "monero_libs" => "monero license",
      _ => "Unknown",
    };

const xmruwVersion = 'v0.0.0-devel';

final extraLicenses = <Package>[
  const Package(
    name: 'unnamed_monero_wallet',
    description:
        'Cross-platform Monero wallet with focus on privacy and security.',
    repository: 'https://git.mrcyjanek.net/mrcyjanek/unnamed_monero_wallet',
    homepage: 'https://xmruw.net',
    authors: [],
    version: xmruwVersion,
    license: null,
    isMarkdown: false,
    isSdk: false,
    isDirectDependency: true,
  ),
  Package(
    name: 'monero_c',
    description: 'Cross-platform C headers to interact with wallet2_api.h',
    repository: 'https://git.mrcyjanek.net/mrcyjanek/monero_c',
    homepage: 'https://xmruw.net',
    authors: [],
    version: ossLicenses.firstWhere((elm) => elm.name == "monero_libs").version,
    license: null,
    isMarkdown: false,
    isSdk: false,
    isDirectDependency: true,
  ),
];

final allLicenses = <Package>[...ossLicenses, ...extraLicenses];

final importantLicenses = [
  "flutter",
  "cupertino_icons",
  "intl",
  "qr_flutter",
  "ffi",
  "monero",
  "path_provider",
  "mutex",
  "monero_libs",
  "cr_file_saver",
  "file_picker",
  "mobile_scanner",
  "bytewords",
  "anonero_backup",
  "flutter_svg",
  "archive",
  "tor_binary",
  "disable_battery_optimization",
  "flutter_background_service",
  "flutter_local_notifications",
  "permission_handler",
  "libstealth_calculator",
  "path",
  "offline_market_data",
  "flex_color_picker",
  "unnamed_monero_wallet",
  "monero_c"
];
