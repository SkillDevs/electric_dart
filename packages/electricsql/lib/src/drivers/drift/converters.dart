import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';

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

class ElectricFloat8Converter extends _ElectricTypeConverter<double, double> {
  const ElectricFloat8Converter() : super(codec: TypeConverters.float8);
}

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
