import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/util/converters/type_converters.dart';

class ElectricTypes {
  static const TimestampType timestamp = TimestampType();
  static const TimestampTZType timestampTZ = TimestampTZType();
  static const DateType date = DateType();
  static const TimeType time = TimeType();
  static const TimeTZType timeTZ = TimeTZType();
  static const UUIDType uuid = UUIDType();
  static const Int2Type int2 = Int2Type();
  static const Int4Type int4 = Int4Type();
  static const Int8Type int8 = Int8Type();
  static const Float4Type float4 = Float4Type();
  static const Float8Type float8 = Float8Type();
  static const JsonType json = JsonType();
  static const JsonBType jsonb = JsonBType();
}

class CustomElectricTypeGeneric<DartT extends Object, SQLType extends Object>
    implements DialectAwareSqlType<DartT> {
  final Codec<DartT, SQLType> codec;
  final String typeName;

  const CustomElectricTypeGeneric({
    required this.codec,
    required this.typeName,
  });

  @override
  String mapToSqlLiteral(GenerationContext context, DartT dartValue) {
    final encoded = codec.encode(dartValue);
    if (encoded is String) {
      return "'$encoded'";
    }
    return '$encoded';
  }

  @override
  Object mapToSqlParameter(GenerationContext context, DartT dartValue) {
    return codec.encode(dartValue);
  }

  @override
  DartT read(SqlTypes types, Object fromSql) {
    return codec.decode(fromSql as SQLType);
  }

  @override
  String sqlTypeName(GenerationContext context) => typeName;
}

abstract class CustomElectricType<DartT extends Object, SQLType extends Object>
    extends CustomElectricTypeGeneric<DartT, SQLType> {
  final PgType pgType;

  const CustomElectricType({
    required super.codec,
    required super.typeName,
    required this.pgType,
  });

  @override
  DartT read(SqlTypes types, Object fromSql) {
    if (types.dialect == SqlDialect.postgres) {
      return fromSql as DartT;
    } else {
      return super.read(types, fromSql);
    }
  }
}

class TimestampType extends CustomElectricType<DateTime, String> {
  const TimestampType()
      : super(
          codec: TypeConverters.timestamp,
          typeName: 'timestamp',
          pgType: PgType.timestamp,
        );
}

class TimestampTZType extends CustomElectricType<DateTime, String> {
  const TimestampTZType()
      : super(
          codec: TypeConverters.timestampTZ,
          typeName: 'timestamptz',
          pgType: PgType.timestampTz,
        );
}

class DateType extends CustomElectricType<DateTime, String> {
  const DateType()
      : super(
          codec: TypeConverters.date,
          typeName: 'date',
          pgType: PgType.date,
        );
}

class TimeType extends CustomElectricType<DateTime, String> {
  const TimeType()
      : super(
          codec: TypeConverters.time,
          typeName: 'time',
          pgType: PgType.time,
        );
}

class TimeTZType extends CustomElectricType<DateTime, String> {
  const TimeTZType()
      : super(
          codec: TypeConverters.timeTZ,
          typeName: 'timetz',
          pgType: PgType.timeTz,
        );
}

class UUIDType extends CustomElectricType<String, String> {
  const UUIDType()
      : super(
          codec: TypeConverters.uuid,
          typeName: 'uuid',
          pgType: PgType.uuid,
        );
}

class Int2Type extends CustomElectricType<int, int> {
  const Int2Type()
      : super(
          codec: TypeConverters.int2,
          typeName: 'int2',
          pgType: PgType.int2,
        );
}

class Int4Type extends CustomElectricType<int, int> {
  const Int4Type()
      : super(
          codec: TypeConverters.int4,
          typeName: 'int4',
          pgType: PgType.int4,
        );
}

class Int8Type extends CustomElectricType<int, int> {
  const Int8Type()
      : super(
          codec: TypeConverters.int8,
          typeName: 'int8',
          pgType: PgType.int8,
        );
}

class Float4Type extends CustomElectricType<double, Object> {
  const Float4Type()
      : super(
          codec: TypeConverters.float4,
          typeName: 'float4',
          pgType: PgType.float4,
        );

  @override
  String mapToSqlLiteral(GenerationContext _, double dartValue) {
    return _doubleToSqlLiteral(codec, dartValue);
  }
}

class Float8Type extends CustomElectricType<double, Object> {
  const Float8Type()
      : super(
          codec: TypeConverters.float8,
          typeName: 'float8',
          pgType: PgType.float8,
        );

  @override
  String mapToSqlLiteral(GenerationContext _, double dartValue) {
    return _doubleToSqlLiteral(codec, dartValue);
  }
}

class JsonType extends CustomElectricType<Object, String> {
  const JsonType()
      : super(
          codec: TypeConverters.json,
          typeName: 'json',
          pgType: PgType.json,
        );
}

class JsonBType extends CustomElectricType<Object, String> {
  const JsonBType()
      : super(
          codec: TypeConverters.jsonb,
          typeName: 'jsonb',
          pgType: PgType.jsonb,
        );
}

String _doubleToSqlLiteral(Codec<double, Object> codec, double dartValue) {
  final encoded = codec.encode(dartValue);

  if (encoded is double && encoded.isInfinite) {
    return encoded.isNegative ? '-9e999' : '9e999';
  } else if (encoded is String) {
    return "'$encoded'";
  }

  return '$encoded';
}
