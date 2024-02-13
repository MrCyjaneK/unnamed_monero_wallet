import 'dart:io';

import 'package:xmruw/tools/is_view_only.dart';

bool canBackup() {
  if (!Platform.isAndroid) return false;
  if (!isAnon) return false;
  return true;
}
