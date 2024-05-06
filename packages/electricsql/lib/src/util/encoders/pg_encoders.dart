import 'dart:convert' as c;

import 'package:electricsql/src/util/encoders/common.dart';
import 'package:electricsql/src/util/encoders/sqlite_encoders.dart';

const kPostgresTypeEncoder = PostgresTypeEncoder();
const kPostgresTypeDecoder = PostgresTypeDecoder();

class PostgresTypeEncoder extends SqliteTypeEncoder {
  const PostgresTypeEncoder();

  @override
  List<int> json(Object j) {
    return c.utf8.encode(c.json.encode(j));
  }

  @override
  List<int> boolean(Object b) {
    if (b is! bool) {
      throw Exception(
        'Invalid boolean value to encode, expected bool, got ${b.runtimeType}',
      );
    }
    return boolToBytes(b);
  }
}

class PostgresTypeDecoder extends SqliteTypeDecoder {
  const PostgresTypeDecoder();

  @override
  Object boolean(List<int> bytes) {
    return bytesToBool(bytes);
  }

  @override
  Object float(List<int> bytes) {
    return bytesToFloat(bytes);
  }
}

List<int> boolToBytes(bool b) {
  return [if (b) trueByte else falseByte];
}

bool bytesToBool(List<int> bs) {
  if (bs.length == 1 && (bs[0] == trueByte || bs[0] == falseByte)) {
    return bs[0] == trueByte;
  }

  throw Exception('Invalid binary-encoded boolean value: $bs');
}

// TODO(dart): Report to official
Object bytesToFloat(List<int> bytes) {
  final text = kPostgresTypeDecoder.text(bytes);
  if (text == 'NaN') {
    return double.nan;
  } else {
    return num.parse(text);
  }
}
