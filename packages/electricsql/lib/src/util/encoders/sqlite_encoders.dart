import 'dart:convert';

import 'package:electricsql/src/util/encoders/common.dart';
import 'package:electricsql/src/util/encoders/types.dart';

const kSqliteTypeEncoder = SqliteTypeEncoder();
const kSqliteTypeDecoder = SqliteTypeDecoder();

class SqliteTypeEncoder implements TypeEncoder {
  const SqliteTypeEncoder();

  @override
  List<int> text(String text) {
    return utf8.encode(text);
  }

  @override
  List<int> json(Object text) {
    if (text is! String) {
      throw Exception(
        'Invalid JSON value to encode, expected String, got ${text.runtimeType}',
      );
    }
    return utf8.encode(text);
  }

  @override
  List<int> boolean(Object b) {
    if (b is! int) {
      throw Exception(
        'Invalid boolean value to encode, expected int, got ${b.runtimeType}',
      );
    }
    return boolToBytes(b);
  }

  @override
  List<int> timetz(String s) {
    return text(stringToTimetzString(s));
  }
}

class SqliteTypeDecoder implements TypeDecoder {
  const SqliteTypeDecoder();

  @override
  String text(List<int> bytes, {bool? allowMalformed}) {
    return bytesToString(bytes, allowMalformed: allowMalformed);
  }

  @override
  String json(List<int> bytes, {bool? allowMalformed}) {
    return bytesToString(bytes, allowMalformed: allowMalformed);
  }

  @override
  int boolean(List<int> bytes) {
    return bytesToBool(bytes);
  }

  @override
  String timetz(List<int> bytes) {
    return bytesToTimetzString(bytes);
  }

  @override
  Object float(List<int> bytes) {
    return bytesToFloat(bytes);
  }
}

List<int> boolToBytes(int b) {
  if (b != 0 && b != 1) {
    throw Exception('Invalid boolean value: $b');
  }
  return [if (b == 1) trueByte else falseByte];
}

int bytesToBool(List<int> bs) {
  if (bs.length == 1 && (bs[0] == trueByte || bs[0] == falseByte)) {
    return bs[0] == trueByte ? 1 : 0;
  }

  throw Exception('Invalid binary-encoded boolean value: $bs');
}

/// Converts a PG string of type `float4` or `float8` to an equivalent SQLite number.
/// Since SQLite does not recognise `NaN` we turn it into the string `'NaN'` instead.
/// cf. https://github.com/WiseLibs/better-sqlite3/issues/1088
/// @param bytes Data for this `float4` or `float8` column.
/// @returns The SQLite value.
Object bytesToFloat(List<int> bytes) {
  final text = kSqliteTypeDecoder.text(bytes);
  if (text == 'NaN') {
    return 'NaN';
  } else {
    return num.parse(text);
  }
}
