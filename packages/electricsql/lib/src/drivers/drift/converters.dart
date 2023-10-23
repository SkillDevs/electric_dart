import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';

class DateType extends CustomElectricType<DateTime, String> {
  const DateType()
      : super(
          codec: TypeConverters.date,
          typeName: 'date',
        );
}

class Int2Type extends CustomElectricType<int, int> {
  const Int2Type()
      : super(
          codec: TypeConverters.int2,
          typeName: 'int2',
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

class ElectricTimestampConverter
    extends _ElectricTypeConverter<DateTime, String> {
  const ElectricTimestampConverter() : super(codec: TypeConverters.timestamp);
}

class ElectricTimestampTZConverter
    extends _ElectricTypeConverter<DateTime, String> {
  const ElectricTimestampTZConverter()
      : super(codec: TypeConverters.timestampTZ);
}

class ElectricDateConverter extends _ElectricTypeConverter<DateTime, String> {
  const ElectricDateConverter() : super(codec: TypeConverters.date);
}

class ElectricTimeConverter extends _ElectricTypeConverter<DateTime, String> {
  const ElectricTimeConverter() : super(codec: TypeConverters.time);
}

class ElectricTimeTZConverter extends _ElectricTypeConverter<DateTime, String> {
  const ElectricTimeTZConverter() : super(codec: TypeConverters.timeTZ);
}

class ElectricUUIDConverter extends _ElectricTypeConverter<String, String> {
  const ElectricUUIDConverter() : super(codec: TypeConverters.uuid);
}

class ElectricInt2Converter extends _ElectricTypeConverter<int, int> {
  const ElectricInt2Converter() : super(codec: TypeConverters.int2);
}

class ElectricInt4Converter extends _ElectricTypeConverter<int, int> {
  const ElectricInt4Converter() : super(codec: TypeConverters.int4);
}

// class ElectricFloat8Converter extends _ElectricTypeConverter<double, double> {
//   const ElectricFloat8Converter() : super(codec: TypeConverters.float8);
// }

@Deprecated("use customType")
abstract class _ElectricTypeConverter<T, Raw> extends TypeConverter<T, Raw> {
  final Codec<T, Raw> codec;

  const _ElectricTypeConverter({required this.codec});

  @override
  T fromSql(Raw fromDb) {
    return codec.decode(fromDb);
  }

  @override
  Raw toSql(T value) {
    return codec.encode(value);
  }
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
