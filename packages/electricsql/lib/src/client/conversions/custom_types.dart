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
  static const Float8Type float8 = Float8Type();
  static const JsonType json = JsonType();
  static const JsonBType jsonb = JsonBType();
}

abstract class CustomElectricType<DartT extends Object, SQLType extends Object>
    implements CustomSqlType<DartT> {
  final Codec<DartT, SQLType> codec;
  final String typeName;
  final PgType pgType;

  const CustomElectricType({
    required this.codec,
    required this.typeName,
    required this.pgType,
  });

  @override
  String mapToSqlLiteral(DartT dartValue) {
    final encoded = codec.encode(dartValue);
    if (encoded is String) {
      return "'$encoded'";
    }
    return '$encoded';
  }

  @override
  Object mapToSqlParameter(DartT dartValue) {
    return codec.encode(dartValue);
  }

  @override
  DartT read(Object fromSql) {
    return codec.decode(fromSql as SQLType);
  }

  @override
  String sqlTypeName(GenerationContext context) => typeName;
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

class Float8Type extends CustomElectricType<double, Object> {
  const Float8Type()
      : super(
          codec: TypeConverters.float8,
          typeName: 'float8',
          pgType: PgType.float8,
        );

  @override
  String mapToSqlLiteral(double dartValue) {
    final encoded = codec.encode(dartValue);

    if (encoded is double && encoded.isInfinite) {
      return encoded.isNegative ? '-9e999' : '9e999';
    } else if (encoded is String) {
      return "'$encoded'";
    }

    return '$encoded';
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
