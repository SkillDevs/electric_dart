import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';

class Int2Type implements CustomSqlType<int> {
  const Int2Type();

  @override
  String mapToSqlLiteral(int dartValue) {
    TypeConverters.int2.encode(dartValue);

    return '$dartValue';
  }

  @override
  Object mapToSqlParameter(int dartValue) {
    TypeConverters.int2.encode(dartValue);

    return dartValue;
  }

  @override
  int read(Object fromSql) {
    return fromSql as int;
  }

  @override
  String sqlTypeName(GenerationContext context) => 'int2';
}

class Float8Type implements CustomSqlType<double> {
  const Float8Type();

  @override
  String mapToSqlLiteral(double dartValue) {
    final encoded = TypeConverters.float8.encode(dartValue);
    return '$encoded';
  }

  @override
  Object mapToSqlParameter(double dartValue) {
    print("ENCODE: $dartValue");
    return TypeConverters.float8.encode(dartValue);

    return dartValue;
  }

  @override
  double read(Object fromSql) {
    return TypeConverters.float8.decode(fromSql);
  }

  @override
  String sqlTypeName(GenerationContext context) => 'int2';
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
