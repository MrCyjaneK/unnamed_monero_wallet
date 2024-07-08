import 'dart:io';

import 'package:path_provider/path_provider.dart';

// https://github.com/juliansteenbakker/mobile_scanner/issues/553
// Basically we got a fucking telemetry because google
// This breaks firebase reporting, so we won't send any requests for using MLkit
// In future we will migrate somewhere else...
// Now instead of a request we get an error:
// android.database.sqlite.SQLiteDatabaseCorruptException: file is not a database (code 26 SQLITE_NOTADB)
// Which is fine, fuck google.
Future<void> fuckFirebase() async {
  if (Platform.isAndroid) {
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.parent.path;
    final file = File('$path/databases/com.google.android.datatransport.events')
      ..createSync(recursive: true);
    await file.writeAsString('Fake');
  }
}
