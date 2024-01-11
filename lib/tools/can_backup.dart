import 'dart:io';

import 'package:anonero/tools/is_view_only.dart';

bool canBackup() {
  if (!Platform.isAndroid) return false;
  if (!isAnon) return false;
  return true;
}
