import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:electricsql/src/client/conversions/postgres/mapping.dart'
    as pg_mapping;
import 'package:electricsql/src/client/conversions/sqlite.dart';
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

abstract class CustomElectricTypeGeneric<DartT extends Object,
    SQLType extends Object> implements DialectAwareSqlType<DartT> {
  final String typeName;

  const CustomElectricTypeGeneric({
    required this.typeName,
  });

  @override
  String sqlTypeName(GenerationContext context) => typeName;
}

abstract class CustomElectricType<DartT extends Object, SQLType extends Object>
    extends CustomElectricTypeGeneric<DartT, SQLType> {
  final PgType pgType;

  const CustomElectricType({
    required super.typeName,
    required this.pgType,
  });

  @override
  Object mapToSqlParameter(GenerationContext context, DartT dartValue) {
    if (context.dialect == SqlDialect.postgres) {
      return pg_mapping.kPostgresConverter.encode(dartValue, pgType)!;
    } else {
      return kSqliteConverter.encode(dartValue, pgType)!;
    }
  }

  @override
  String mapToSqlLiteral(GenerationContext context, DartT dartValue) {
    if (context.dialect == SqlDialect.postgres) {
      return pg_mapping.mapToSqlLiteral(pgType, dartValue, typeName);
    } else {
      final encoded = kSqliteConverter.encode(dartValue, pgType)!;
      if (encoded is String) {
        return "'$encoded'";
      }
      return '$encoded';
    }
  }

  @override
  DartT read(SqlTypes types, Object fromSql) {
    if (types.dialect == SqlDialect.postgres) {
      final decoded = pg_mapping.kPostgresConverter.decode(fromSql, pgType)!;
      return decoded as DartT;
    } else {
      final decoded = kSqliteConverter.decode(fromSql, pgType)!;
      return decoded as DartT;
    }
  }
}

class CustomElectricTypeEnum<DartT extends Object>
    extends CustomElectricTypeGeneric<DartT, String> {
  final Codec<DartT, String> codec;

  const CustomElectricTypeEnum({
    required this.codec,
    required super.typeName,
  });

  @override
  String mapToSqlLiteral(GenerationContext context, DartT dartValue) {
    final String encoded = codec.encode(dartValue);
    return "'$encoded'";
  }

  @override
  Object mapToSqlParameter(GenerationContext context, DartT dartValue) {
    if (context.dialect == SqlDialect.postgres) {
      // Enums are treated as null pgtype
      const PgType? pgType = null;
      final String enumStr = codec.encode(dartValue);
      return pg_mapping.mapToSql(pgType, enumStr);
    } else {
      return codec.encode(dartValue);
    }
  }

  @override
  DartT read(SqlTypes types, Object fromSql) {
    if (types.dialect == SqlDialect.postgres) {
      return pg_mapping.mapToUser(null, fromSql, codec) as DartT;
    } else {
      return codec.decode(fromSql as String);
    }
  }
}

class TimestampType extends CustomElectricType<DateTime, String> {
  const TimestampType()
      : super(
          typeName: 'timestamp',
          pgType: PgType.timestamp,
        );
}

class TimestampTZType extends CustomElectricType<DateTime, String> {
  const TimestampTZType()
      : super(
          typeName: 'timestamptz',
          pgType: PgType.timestampTz,
        );
}

class DateType extends CustomElectricType<DateTime, String> {
  const DateType()
      : super(
          typeName: 'date',
          pgType: PgType.date,
        );
}

class TimeType extends CustomElectricType<DateTime, String> {
  const TimeType()
      : super(
          typeName: 'time',
          pgType: PgType.time,
        );
}

class TimeTZType extends CustomElectricType<DateTime, String> {
  const TimeTZType()
      : super(
          typeName: 'timetz',
          pgType: PgType.timeTz,
        );
}

class UUIDType extends CustomElectricType<String, String> {
  const UUIDType()
      : super(
          typeName: 'uuid',
          pgType: PgType.uuid,
        );
}

class Int2Type extends CustomElectricType<int, int> {
  const Int2Type()
      : super(
          typeName: 'int2',
          pgType: PgType.int2,
        );
}

class Int4Type extends CustomElectricType<int, int> {
  const Int4Type()
      : super(
          typeName: 'int4',
          pgType: PgType.int4,
        );
}

class Int8Type extends CustomElectricType<int, int> {
  const Int8Type()
      : super(
          typeName: 'int8',
          pgType: PgType.int8,
        );
}

class Float4Type extends CustomElectricType<double, Object> {
  const Float4Type()
      : super(
          typeName: 'float4',
          pgType: PgType.float4,
        );

  @override
  String mapToSqlLiteral(GenerationContext context, double dartValue) {
    if (context.dialect == SqlDialect.sqlite) {
      return _doubleToSqliteLiteral(TypeConverters.float4, dartValue);
    } else {
      return super.mapToSqlLiteral(context, dartValue);
    }
  }
}

class Float8Type extends CustomElectricType<double, Object> {
  const Float8Type()
      : super(
          typeName: 'float8',
          pgType: PgType.float8,
        );

  @override
  String mapToSqlLiteral(GenerationContext context, double dartValue) {
    if (context.dialect == SqlDialect.sqlite) {
      return _doubleToSqliteLiteral(TypeConverters.float8, dartValue);
    } else {
      return super.mapToSqlLiteral(context, dartValue);
    }
  }
}

class JsonType extends CustomElectricType<Object, String> {
  const JsonType()
      : super(
          typeName: 'json',
          pgType: PgType.json,
        );
}

class JsonBType extends CustomElectricType<Object, String> {
  const JsonBType()
      : super(
          typeName: 'jsonb',
          pgType: PgType.jsonb,
        );
}

String _doubleToSqliteLiteral(
  Codec<double, Object> codec,
  double dartValue,
) {
  final encoded = codec.encode(dartValue);

  if (encoded is double && encoded.isInfinite) {
    return encoded.isNegative ? '-9e999' : '9e999';
  } else if (encoded is String) {
    return "'$encoded'";
  }

  return '$encoded';
}
