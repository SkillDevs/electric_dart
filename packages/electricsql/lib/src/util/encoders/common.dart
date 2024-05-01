import 'dart:convert';
import 'dart:typed_data';

final trueByte = 't'.codeUnitAt(0);
final falseByte = 'f'.codeUnitAt(0);

List<int> numberToBytes(int i) {
  return [
    (i & 0xff000000) >> 24,
    (i & 0x00ff0000) >> 16,
    (i & 0x0000ff00) >> 8,
    (i & 0x000000ff) >> 0,
  ];
}

int bytesToNumber(List<int> bytes) {
  int n = 0;
  for (final byte in bytes) {
    n = (n << 8) | byte;
  }
  return n;
}

String bytesToString(List<int> bytes, {bool? allowMalformed}) {
  return utf8.decode(bytes, allowMalformed: allowMalformed);
}

/// Converts a PG string of type `timetz` to its equivalent SQLite string.
/// e.g. '18:28:35.42108+00' -> '18:28:35.42108'
/// @param bytes Data for this `timetz` column.
/// @returns The SQLite string.
String bytesToTimetzString(List<int> bytes) {
  final str = bytesToString(bytes);
  return str.replaceAll('+00', '');
}

/// Converts an arbitrary blob (or bytestring) into a hex encoded string, which
/// is also the `bytea` PG string.
/// @param bytes - the blob to encode
/// @returns the blob as a hex encoded string
String blobToHexString(List<int> bytes) {
  final StringBuffer hexString = StringBuffer();
  for (final byte in bytes) {
    hexString.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return hexString.toString();
}

/// Converts a hex encoded string into a `Uint8Array` blob.
/// @param bytes - the blob to encode
/// @returns the blob as a hex encoded string
List<int> hexStringToBlob(String hexString) {
  if (hexString.length % 2 != 0) {
    hexString = '0$hexString';
  }

  final byteArray = Uint8List(hexString.length ~/ 2);
  for (int i = 0; i < hexString.length; i += 2) {
    final byte = int.parse(hexString.substring(i, i + 2), radix: 16);
    byteArray[i ~/ 2] = byte;
  }
  return byteArray;
}

/// Converts a SQLite string representing a `timetz` value to a PG string.
/// e.g. '18:28:35.42108' -> '18:28:35.42108+00'
/// @param str The SQLite string representing a `timetz` value.
/// @returns The PG string.
String stringToTimetzString(String str) {
  return '$str+00';
}
