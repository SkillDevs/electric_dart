import 'package:electricsql/src/client/model/index.dart';
import 'package:electricsql/src/util/converters/helpers.dart';
import 'package:electricsql/src/util/converters/type_converters.dart';

const kSqliteConverter = SQLiteConverter();

class SQLiteConverter implements Converter {
  const SQLiteConverter();

  @override
  Object? encode(Object? v, PgType pgType) {
    if (v == null) return null;

    final Object sqlVal = switch (pgType) {
      PgType.bool => (v as bool) ? 1 : 0,
      PgType.timestamp => TypeConverters.timestamp.encode(v as DateTime),
      PgType.timestampTz => TypeConverters.timestampTZ.encode(v as DateTime),
      PgType.date => TypeConverters.date.encode(v as DateTime),
      PgType.time => TypeConverters.time.encode(v as DateTime),
      PgType.timeTz => TypeConverters.timeTZ.encode(v as DateTime),
      PgType.uuid => TypeConverters.uuid.encode(v as String),
      PgType.int2 => TypeConverters.int2.encode(v as int),
      PgType.int ||
      PgType.int4 ||
      PgType.integer =>
        TypeConverters.int4.encode(v as int),
      PgType.int8 => switch (v) {
          int() => TypeConverters.int8.encode(v),
          BigInt() => v.rangeCheckedToInt(),
          _ => throw ArgumentError('Invalid type for int8: $v'),
        },
      PgType.real || PgType.float4 => TypeConverters.float4.encode(v as double),
      PgType.float8 => TypeConverters.float8.encode(v as double),
      PgType.json => TypeConverters.json.encode(v),
      PgType.jsonb => TypeConverters.jsonb.encode(v),
      _ => v,
    };
    return sqlVal;
  }

  @override
  Object? decode(Object? v, PgType pgType) {
    if (v == null) return null;

    final Object dartVal = switch (pgType) {
      PgType.bool => (v as int) == 1,
      PgType.timestamp => TypeConverters.timestamp.decode(v as String),
      PgType.timestampTz => TypeConverters.timestampTZ.decode(v as String),
      PgType.date => TypeConverters.date.decode(v as String),
      PgType.time => TypeConverters.time.decode(v as String),
      PgType.timeTz => TypeConverters.timeTZ.decode(v as String),
      PgType.uuid => TypeConverters.uuid.decode(v as String),
      PgType.int2 => TypeConverters.int2.decode(v as int),
      PgType.int ||
      PgType.int4 ||
      PgType.integer =>
        TypeConverters.int4.decode(v as int),
      PgType.int8 => TypeConverters.int8.decode(v as int),
      PgType.real || PgType.float4 => TypeConverters.float4.decode(v),
      PgType.float8 => TypeConverters.float8.decode(v),
      PgType.json => TypeConverters.json.decode(v as String),
      PgType.jsonb => TypeConverters.jsonb.decode(v as String),
      _ => v,
    };
    return dartVal;
  }
}
