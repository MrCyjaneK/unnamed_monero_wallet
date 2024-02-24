import 'dart:io';

import 'package:xmruw/pages/config/base.dart';

bool canPlatformScan() {
  if (config.forceEnableScanner) return true;
  if (Platform.isAndroid || Platform.isIOS) return true;
  return false;
}

bool canPlatformText() {
  if (config.forceEnableText) return true;
  if (Platform.isAndroid || Platform.isIOS) return false;
  return true;
}
