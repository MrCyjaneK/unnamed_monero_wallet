import 'dart:convert';
import 'dart:io';

import 'package:xmruw/tools/dirs.dart';
import 'package:monero/monero.dart';

Future<void> loadPerfData() async {
  final pmf = File(await getPerformanceStoreFile());
  try {
    if (pmf.existsSync()) {
      final perfData =
          json.decode(pmf.readAsStringSync()) as Map<String, dynamic>;
      debugCallLength = perfData.map((key, value) {
        return MapEntry(
            key,
            (value as List<dynamic>).map((e) {
              return e as int;
            }).toList());
      });
    }
  } catch (e) {
    print(e);
  }
}
