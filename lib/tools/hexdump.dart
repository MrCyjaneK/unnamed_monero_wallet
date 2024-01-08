import 'dart:typed_data';

String hexDump(Uint8List privateBytes, {String? name}) {
  // Dump bytes in hex

  final hex = StringBuffer();

  if (name != null) {
    hex.write('$name = ');
  }

  hex.write('[');

  var n = 32;
  for (final c in privateBytes) {
    if (n == 32) {
      hex.write('\n');
      n = 0;
    } else if (n % 4 == 0) {
      hex.write(' ');
    }
    final s = c.toRadixString(16);
    if (s.length < 2) {
      hex.write('0');
    }
    hex
      ..write(s)
      ..write(' ');
    n++;
  }
  hex.write(']\n');

  return hex.toString();
}
