import 'package:electricsql/src/client/conversions/types.dart';
import 'package:postgres/postgres.dart' as pg;

Object mapToSql(PgType type, Object dartValue) {
  return switch (type) {
    PgType.bool => pg.TypedValue(pg.Type.boolean, dartValue),
    PgType.int ||
    PgType.int4 ||
    PgType.integer =>
      pg.TypedValue(pg.Type.integer, dartValue),
    PgType.int2 => pg.TypedValue(pg.Type.smallInteger, dartValue),
    PgType.int8 => pg.TypedValue(pg.Type.bigInteger, dartValue),
    PgType.real || PgType.float4 => pg.TypedValue(pg.Type.real, dartValue),
    PgType.float8 => pg.TypedValue(pg.Type.double, dartValue),
    PgType.text => pg.TypedValue(pg.Type.text, dartValue),
    PgType.varchar => pg.TypedValue(pg.Type.varChar, dartValue),
    PgType.char => pg.TypedValue(pg.Type.character, dartValue),
    PgType.uuid => pg.TypedValue(pg.Type.uuid, dartValue),
    PgType.json => pg.TypedValue(pg.Type.json, dartValue),
    PgType.jsonb => pg.TypedValue(pg.Type.jsonb, dartValue),
    PgType.timestamp ||
    PgType.time =>
      pg.TypedValue(pg.Type.timestampWithoutTimezone, dartValue),
    PgType.timestampTz ||
    PgType.timeTz =>
      pg.TypedValue(pg.Type.timestampWithTimezone, dartValue),
    PgType.date => pg.TypedValue(pg.Type.date, dartValue),
  };
}
