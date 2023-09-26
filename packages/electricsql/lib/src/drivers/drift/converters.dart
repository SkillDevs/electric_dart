import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';

class ElectricTimestampConverter extends _ElectricDateTypeConverter {
  const ElectricTimestampConverter() : super(codec: TypeConverters.timestamp);
}

class ElectricTimestampTZConverter extends _ElectricDateTypeConverter {
  const ElectricTimestampTZConverter()
      : super(codec: TypeConverters.timestampTZ);
}

class ElectricDateConverter extends _ElectricDateTypeConverter {
  const ElectricDateConverter() : super(codec: TypeConverters.date);
}

class ElectricTimeConverter extends _ElectricDateTypeConverter {
  const ElectricTimeConverter() : super(codec: TypeConverters.time);
}

class ElectricTimeTZConverter extends _ElectricDateTypeConverter {
  const ElectricTimeTZConverter() : super(codec: TypeConverters.timeTZ);
}

abstract class _ElectricDateTypeConverter
    extends TypeConverter<DateTime, String> {
  final Codec<DateTime, String> codec;

  const _ElectricDateTypeConverter({required this.codec});

  @override
  DateTime fromSql(String fromDb) {
    return codec.decode(fromDb);
  }

  @override
  String toSql(DateTime value) {
    return codec.encode(value);
  }
}
