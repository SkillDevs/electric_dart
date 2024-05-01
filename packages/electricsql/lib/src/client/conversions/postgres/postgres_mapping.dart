import 'dart:convert';

import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/util/converters/codecs/float4.dart';
import 'package:electricsql/src/util/converters/codecs/int2.dart';
import 'package:electricsql/src/util/converters/codecs/int4.dart';
import 'package:electricsql/src/util/converters/codecs/json.dart';
import 'package:electricsql/src/util/converters/codecs/uuid.dart';
import 'package:electricsql/src/util/converters/helpers.dart';
import 'package:postgres/postgres.dart' as pg;

// ignore: implementation_imports
import 'package:postgres/src/types/text_codec.dart';

Object mapToSql(PgType? type, Object inputDartValue) {
  final pg.Type pgType = _mapElectricPgType(type);
  final dartValue = _updateDartInput(pgType, inputDartValue, isLiteral: false);

  final pg.TypedValue typedValue;
  if (type == null) {
    // Enum as string
    typedValue = pg.TypedValue(pgType, dartValue as String);
  } else if (dartValue == null) {
    // Don't infer SQL nulls. At this level, SQL nulls have been handled.
    // This can happen when inserting Json null values
    typedValue = pg.TypedValue(pgType, null, isSqlNull: false);
  } else {
    typedValue = pg.TypedValue(pgType, dartValue);
  }

  return typedValue;
}

pg.Type _mapElectricPgType(PgType? pgType) {
  final pg.Type type = switch (pgType) {
    PgType.bool => pg.Type.boolean,
    PgType.int || PgType.int4 || PgType.integer => pg.Type.integer,
    PgType.int2 => pg.Type.smallInteger,
    PgType.int8 => pg.Type.bigInteger,
    PgType.real || PgType.float4 => pg.Type.real,
    PgType.float8 => pg.Type.double,
    PgType.text => pg.Type.text,
    PgType.varchar => pg.Type.varChar,
    PgType.char => pg.Type.character,
    PgType.uuid => pg.Type.uuid,
    PgType.json => pg.Type.json,
    PgType.jsonb => pg.Type.jsonb,
    PgType.time => pg.Type.time,
    PgType.timestamp => pg.Type.timestamp,
    PgType.timestampTz => pg.Type.timestampWithTimezone,
    PgType.date => pg.Type.date,
    PgType.bytea => pg.Type.byteArray,
    // We use the string representation for the enums
    // Because we don't have the oid, we need to use Type.unspecified
    null => pg.Type.unspecified,
    // TIMETZ is not supported by the Postgres package
    PgType.timeTz => throw UnimplementedError(),
  };
  return type;
}

const _pgEncoder = PostgresTextEncoder();

String mapToSqlLiteral(
  PgType pgType,
  Object inputDartValue,
  String typeName,
  Codec<Object, Object> codec,
) {
  final pgLibType = _mapElectricPgType(pgType);
  final dartValue =
      _updateDartInput(pgLibType, inputDartValue, isLiteral: true);

  final String pgEncoded;

  // print("PGTYPE $pgType");

  if (pgType == PgType.date) {
    pgEncoded =
        _encodeDateTimeWithoutTZ(dartValue as DateTime, isDateOnly: true);
  } else if (pgType == PgType.time) {
    pgEncoded = _encodeDateTimeWithoutTZ(
      (dartValue as pg.Time).utcDateTime,
      isTimeOnly: true,
    );
  } else if (pgType == PgType.timestamp) {
    pgEncoded = _encodeDateTimeWithoutTZ(dartValue as DateTime);
  } else if (pgType == PgType.json || pgType == PgType.jsonb) {
    final jsonEncoded = dartValue == null
        ? 'null'
        : codec.encode(dartValue as Object) as String;
    pgEncoded = _pgEncoder.convert(jsonEncoded);
  } else if (pgType == PgType.float4 && dartValue is num) {
    final dd = fround(dartValue);
    pgEncoded = _pgEncoder.convert(dd);
  } else {
    pgEncoded = _pgEncoder.convert(dartValue as Object);
  }

  return pgEncoded;
}

Object mapToUser(PgType? type, Object sqlValue, Codec<Object, Object> codec) {
  if (type == PgType.time) {
    return (sqlValue as pg.Time).utcDateTime;
  } else if (type == null) {
    final enumStr = _readEnum(sqlValue);
    return codec.decode(enumStr);
  } else {
    return sqlValue;
  }
}

String _readEnum(Object sqlValue) {
  if (sqlValue is String) return sqlValue;
  final enumStr = (sqlValue as pg.UndecodedBytes).asString;
  return enumStr;
}

// Taken from the postgres package
String _encodeDateTimeWithoutTZ(
  DateTime value, {
  bool isDateOnly = false,
  bool isTimeOnly = false,
}) {
  var string = value.toIso8601String();

  if (isDateOnly) {
    string = string.split('T').first;
  } else if (isTimeOnly) {
    string = string.split('T').last;
  }

  if (string.substring(0, 1) == '-') {
    string = '${string.substring(1)} BC';
  } else if (string.substring(0, 1) == '+') {
    string = string.substring(1);
  }

  return "'$string'";
}

dynamic _updateDartInput(
  pg.Type pgType,
  Object dartValue, {
  required bool isLiteral,
}) {
  // Validations
  if (pgType == pg.Type.uuid) {
    UUIDCodec.validateString(dartValue as String);
  } else if (pgType == pg.Type.smallInteger) {
    Int2Codec.validateInt(dartValue as int);
  } else if (pgType == pg.Type.integer) {
    Int4Codec.validateInt(dartValue as int);
  }

  if (dartValue is DateTime) {
    if (pgType == pg.Type.timestampWithoutTimezone) {
      dartValue = dartValue.asUtc();
    } else if (pgType == pg.Type.date) {
      dartValue = DateTime.utc(
        dartValue.year,
        dartValue.month,
        dartValue.day,
      );
    } else if (pgType == pg.Type.time) {
      dartValue = pg.Time(
        dartValue.hour,
        dartValue.minute,
        dartValue.second,
        dartValue.millisecond,
        dartValue.microsecond,
      );
    }
  } else if (isJsonNull(dartValue) &&
      (pgType == pg.Type.json || pgType == pg.Type.jsonb)) {
    return null;
  }

  return dartValue;
}
