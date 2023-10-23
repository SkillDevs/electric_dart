import 'dart:convert';

import 'package:drift/drift.dart';
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
}

abstract class CustomElectricType<DartT extends Object, SQLType extends Object>
    implements CustomSqlType<DartT> {
  final Codec<DartT, SQLType> codec;
  final String typeName;

  const CustomElectricType({required this.codec, required this.typeName});

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
        );
}

class TimestampTZType extends CustomElectricType<DateTime, String> {
  const TimestampTZType()
      : super(
          codec: TypeConverters.timestampTZ,
          typeName: 'timestamptz',
        );
}

class DateType extends CustomElectricType<DateTime, String> {
  const DateType()
      : super(
          codec: TypeConverters.date,
          typeName: 'date',
        );
}

class TimeType extends CustomElectricType<DateTime, String> {
  const TimeType()
      : super(
          codec: TypeConverters.time,
          typeName: 'time',
        );
}

class TimeTZType extends CustomElectricType<DateTime, String> {
  const TimeTZType()
      : super(
          codec: TypeConverters.timeTZ,
          typeName: 'timetz',
        );
}

class UUIDType extends CustomElectricType<String, String> {
  const UUIDType()
      : super(
          codec: TypeConverters.uuid,
          typeName: 'uuid',
        );
}

class Int2Type extends CustomElectricType<int, int> {
  const Int2Type()
      : super(
          codec: TypeConverters.int2,
          typeName: 'int2',
        );
}

class Int4Type extends CustomElectricType<int, int> {
  const Int4Type()
      : super(
          codec: TypeConverters.int4,
          typeName: 'int4',
        );
}

class Float8Type extends CustomElectricType<double, Object> {
  const Float8Type()
      : super(
          codec: TypeConverters.float8,
          typeName: 'float8',
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
