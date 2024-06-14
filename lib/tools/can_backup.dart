import 'dart:io';

bool canBackup() {
  if (!Platform.isAndroid) return false;
  return true;
}
