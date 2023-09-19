import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/util/converters/helpers.dart';

class ElectricTimestampConverter extends TypeConverter<DateTime, String> {
  const ElectricTimestampConverter();

  @override
  DateTime fromSql(String fromDb) {
    return TypeConverters.timestamp.decode(fromDb);
  }

  @override
  String toSql(DateTime value) {
    return TypeConverters.timestamp.encode(value);
  }
}

class ElectricDateConverter extends TypeConverter<DateTime, String> {
  const ElectricDateConverter();

  @override
  DateTime fromSql(String fromDb) {
    return DateTime.parse(fromDb).toUtc();
  }

  @override
  String toSql(DateTime value) {
    return value.toISOStringUTC();
  }
}

class ElectricTimeConverter extends TypeConverter<DateTime, String> {
  const ElectricTimeConverter();

  @override
  DateTime fromSql(String fromDb) {
    return DateTime.parse(fromDb).toUtc();
  }

  @override
  String toSql(DateTime value) {
    return value.toISOStringUTC();
  }
}
