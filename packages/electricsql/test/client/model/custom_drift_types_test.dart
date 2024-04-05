import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:electricsql/src/client/conversions/custom_types.dart';
import 'package:electricsql/src/util/converters/codecs/float4.dart';
import 'package:electricsql/src/util/converters/codecs/json.dart';
import 'package:electricsql/src/util/converters/helpers.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:test/test.dart';

import '../drift/client_test_util.dart';
import '../drift/database.dart';
import '../drift/generated/electric/drift_schema.dart';

void main() async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = TestsDatabase.memory();

  await electrifyTestDatabase(db);

  setUp(() async {
    await initClientTestsDb(db);
  });

  group('date', () {
    test('today', () async {
      final today = DateTime.now();

      await _testDate(db, today);
    });

    test('today with extra info', () async {
      final today = DateTime.now();
      await _testDate(db, today);
    });

    test('local at edge', () async {
      // 2000-01-15 00:05:00
      await _testDate(
        db,
        DateTime(2000, 1, 15, 0, 5),
        expected: DateTime.utc(2000, 1, 15),
      );
    });

    test('local at edge 2', () async {
      // 2000-01-15 23:55:00
      await _testDate(
        db,
        DateTime(2000, 1, 15, 23, 55),
        expected: DateTime.utc(2000, 1, 15),
      );
    });

    test('utc at edge 1', () async {
      // 2000-01-15 00:05:00
      await _testDate(
        db,
        DateTime.utc(2000, 1, 15, 0, 5),
        expected: DateTime.utc(2000, 1, 15),
      );
    });

    test('utc at edge 2', () async {
      // 2000-01-15 23:55:00
      await _testDate(
        db,
        DateTime.utc(2000, 1, 15, 23, 55),
        expected: DateTime.utc(2000, 1, 15),
      );
    });

    test('utc', () async {
      final today = DateTime.now().toUtc();
      await _testDate(db, today);
    });

    test('min', () async {
      await _testDate(db, DateTime(1));
    });

    test('max', () async {
      await _testDate(db, DateTime(9999, 12, 31));
    });
  });

  group('time', () {
    test('now', () async {
      final now = DateTime.now();
      await _testTime(db, now);
    });

    test('regular', () async {
      final date = DateTime.parse('2023-08-07 18:28:35.421');
      await _testTime(db, date);
    });

    test('min', () async {
      await _testTime(db, DateTime(1));
    });

    test('max', () async {
      await _testTime(db, DateTime(9999, 12, 31, 23, 59, 59, 999, 999));
    });
  });

  group('timetz', () {
    test('regular 1', () async {
      final date = DateTime.parse('2023-08-07 18:28:35.421+03');
      await _testTimeTZ(db, date);
    });

    test('regular 2', () async {
      final date = DateTime.parse('2023-08-07 18:28:35.421+02');
      await _testTimeTZ(db, date);
    });
  });

  group('timestamp', () {
    test('now', () async {
      final now = DateTime.now();
      await _testTimestamp(db, now);
    });

    test('regular', () async {
      final date = DateTime.parse('2023-08-07 18:28:35.421');
      await _testTimestamp(
        db,
        date,
        expected: DateTime.utc(2023, 8, 7, 18, 28, 35, 421),
      );
    });

    test('regular 2', () async {
      final date = DateTime.parse('2023-08-07 18:28:35');
      await _testTimestamp(
        db,
        date,
        expected: DateTime.utc(2023, 8, 7, 18, 28, 35),
      );
    });

    test('utc', () async {
      final now = DateTime.now().toUtc();
      await _testTimestamp(db, now);
    });

    test('min', () async {
      await _testTimestamp(db, DateTime(1));
    });

    test('max', () async {
      await _testTimestamp(db, DateTime(9999, 12, 31, 23, 59, 59, 999, 999));
    });
  });

  group('timestamptz', () {
    test('regular 1', () async {
      final date = DateTime.parse('2023-08-07 18:28:35.421+03');
      await _testTimestampTZ(db, date);
    });

    test('regular 2', () async {
      final date = DateTime.parse('2023-08-07 18:28:35.421+02');
      await _testTimestampTZ(db, date);
    });
  });

  group('bool', () {
    test('true', () async {
      await _testBool(db, true);
    });

    test('false', () async {
      await _testBool(db, false);
    });
  });

  group('uuid', () {
    test('regular', () async {
      await _testUUID(db, '123e4567-e89b-12d3-a456-426655440000');
    });

    test('empty', () async {
      await _testUUID(db, '00000000-0000-0000-0000-000000000000');
    });
  });

  group('int2', () {
    test('regular', () async {
      await _testInt2(db, 2);
    });

    test('0', () async {
      await _testInt2(db, 0);
    });

    test('max', () async {
      await _testInt2(db, 32767);
    });

    test('min', () async {
      await _testInt2(db, -32768);
    });
  });

  group('int4', () {
    test('regular', () async {
      await _testInt4(db, 2);
    });

    test('0', () async {
      await _testInt4(db, 0);
    });

    test('max', () async {
      await _testInt4(db, 2147483647);
    });

    test('min', () async {
      await _testInt4(db, -2147483648);
    });
  });

  group('int8', () {
    test('regular', () async {
      await _testInt8(db, 2);
    });

    test('0', () async {
      await _testInt8(db, 0);
    });

    test('max', () async {
      await _testInt8(db, 9223372036854775807);
    });

    test('min', () async {
      await _testInt8(db, -9223372036854775808);
    });
  });

  group('int8 bigint', () {
    test('regular', () async {
      await _testInt8BigInt(db, BigInt.from(2));
    });

    test('0', () async {
      await _testInt8BigInt(db, BigInt.from(0));
    });

    test('max', () async {
      await _testInt8BigInt(db, BigInt.from(9223372036854775807));
    });

    test('min', () async {
      await _testInt8BigInt(db, BigInt.from(-9223372036854775808));
    });

    test('invalid', () async {
      await expectLater(
        () async => _testInt8BigInt(db, BigInt.parse('9223372036854775808')),
        throwsA(isA<Exception>()),
      );

      await expectLater(
        () async => _testInt8BigInt(db, BigInt.parse('-9223372036854775809')),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('float4', () {
    test('regular', () async {
      await _testFloat4(
        db,
        1.402823e36,
        expected: fround(1.402823e36),
      );
    });

    test('0', () async {
      await _testFloat4(db, 0);
    });

    test('too positive', () async {
      await _testFloat4(db, 1.42724769270596e+45, expected: double.infinity);
    });

    test('too negative', () async {
      await _testFloat4(
        db,
        -1.42724769270596e+45,
        expected: double.negativeInfinity,
      );
    });

    test('too small positive', () async {
      await _testFloat4(db, 7.006492321624085e-46, expected: 0);
    });

    test('too small negative', () async {
      await _testFloat4(db, -7.006492321624085e-46, expected: 0);
    });

    test('infinite', () async {
      await _testFloat4(db, double.infinity);
    });

    test('negative infinite', () async {
      await _testFloat4(db, double.negativeInfinity);
    });

    test('NaN', () async {
      await _testFloat4(db, double.nan);
    });
  });

  group('float8', () {
    test('regular', () async {
      await _testFloat8(db, 2.5);
    });

    test('0', () async {
      await _testFloat8(db, 0);
    });

    test('max finite', () async {
      await _testFloat8(db, double.maxFinite);
    });

    test('min finite', () async {
      await _testFloat8(db, -double.maxFinite);
    });

    test('min positive', () async {
      await _testFloat8(db, double.minPositive);
    });

    test('negative min positive', () async {
      await _testFloat8(db, -double.minPositive);
    });

    test('infinite', () async {
      await _testFloat8(db, double.infinity);
    });

    test('negative infinite', () async {
      await _testFloat8(db, double.negativeInfinity);
    });

    test('NaN', () async {
      await _testFloat8(db, double.nan);
    });
  });

  group('json', () {
    test('int', () async {
      await _testJson(db, 1);
    });

    test('double', () async {
      await _testJson(db, 1.5);
    });

    test('string', () async {
      await _testJson(db, 'hello');
    });

    test('list', () async {
      await _testJson(db, [1, 2, 3]);
    });

    test('map', () async {
      await _testJson(db, {'a': 1, 'b': 2});
    });

    test('null', () async {
      await _testJson(db, kJsonNull);
    });

    test('true', () async {
      await _testJson(db, true);
    });

    test('invalid', () async {
      await expectLater(
        () async => _testJson(db, Object()),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });
  });

  group('enum', () {
    test('regular', () async {
      await _testColorEnum(db, DbColor.blue);
    });
  });

  group('bytea', () {
    test('regular', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      await _testBytea(db, bytes);
    });

    test('empty', () async {
      final bytes = Uint8List.fromList([]);
      await _testBytea(db, bytes);
    });
  });
}

Future<void> _testDate(
  TestsDatabase db,
  DateTime value, {
  DateTime? expected,
}) async {
  final effectiveExpected = expected ??
      // hours, min, secs, millis and microseconds removed
      value.asUtc().copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          );

  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.date,
    insertCol: (c, v) => c.copyWith(
      date: Value(v),
    ),
    customT: ElectricTypes.date,
    expected: effectiveExpected,
  );
}

Future<void> _testTime(TestsDatabase db, DateTime value) async {
  // Day and microseconds removed
  final expected = value.asUtc().copyWith(
        year: 1970,
        month: 1,
        day: 1,
        microsecond: 0,
      );

  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.time,
    insertCol: (c, v) => c.copyWith(
      time: Value(v),
    ),
    customT: ElectricTypes.time,
    expected: expected,
  );
}

Future<void> _testTimeTZ(TestsDatabase db, DateTime value) async {
  // Day and microseconds removed
  final expected = value
      .copyWith(
        year: 1970,
        month: 1,
        day: 1,
        microsecond: 0,
      )
      .toUtc();

  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.timetz,
    insertCol: (c, v) => c.copyWith(
      timetz: Value(v),
    ),
    customT: ElectricTypes.timeTZ,
    expected: expected,
  );
}

Future<void> _testTimestamp(
  TestsDatabase db,
  DateTime value, {
  DateTime? expected,
}) async {
  final DateTime effectiveExpected = expected ??
      value
          .asUtc() //
          .copyWith(microsecond: 0);

  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.timestamp,
    insertCol: (c, v) => c.copyWith(
      timestamp: Value(v),
    ),
    customT: ElectricTypes.timestamp,
    expected: effectiveExpected,
  );
}

Future<void> _testTimestampTZ(TestsDatabase db, DateTime value) async {
  final expected = value
      .copyWith(
        microsecond: 0,
      )
      .toUtc();

  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.timestamptz,
    insertCol: (c, v) => c.copyWith(
      timestamptz: Value(v),
    ),
    customT: ElectricTypes.timestampTZ,
    expected: expected,
  );
}

Future<void> _testBool(TestsDatabase db, bool value) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.bool$,
    insertCol: (c, v) => c.copyWith(
      bool$: Value(v),
    ),
    // We can use Drift default bool type
    customT: null,
  );
}

Future<void> _testUUID(TestsDatabase db, String value) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.uuid,
    insertCol: (c, v) => c.copyWith(
      uuid: Value(v),
    ),
    customT: ElectricTypes.uuid,
  );
}

Future<void> _testInt2(TestsDatabase db, int value) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.int2,
    insertCol: (c, v) => c.copyWith(
      int2: Value(v),
    ),
    customT: ElectricTypes.int2,
  );
}

Future<void> _testInt4(TestsDatabase db, int value) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.int4,
    insertCol: (c, v) => c.copyWith(
      int4: Value(v),
    ),
    customT: ElectricTypes.int4,
  );
}

Future<void> _testInt8(TestsDatabase db, int value) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.int8,
    insertCol: (c, v) => c.copyWith(
      int8: Value(v),
    ),
    customT: ElectricTypes.int8,
  );
}

Future<void> _testInt8BigInt(TestsDatabase db, BigInt value) async {
  await _testCustomTypeExtra(
    db,
    value: value,
    column: db.extra.int8BigInt,
    insertCol: (c, v) => c.copyWith(
      int8BigInt: Value(v),
    ),
    // We can use Drift default BigInt type
    customT: null,
  );
}

Future<void> _testFloat8(TestsDatabase db, double value) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.float8,
    insertCol: (c, v) => c.copyWith(
      float8: Value(v),
    ),
    customT: ElectricTypes.float8,
  );
}

Future<void> _testFloat4(
  TestsDatabase db,
  double value, {
  double? expected,
}) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.float4,
    insertCol: (c, v) => c.copyWith(
      float4: Value(v),
    ),
    customT: ElectricTypes.float4,
    expected: expected,
  );
}

Future<void> _testJson(TestsDatabase db, Object value) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.json,
    insertCol: (c, v) => c.copyWith(
      json: Value(v),
    ),
    customT: ElectricTypes.json,
  );
}

Future<void> _testBytea(TestsDatabase db, Uint8List value) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.bytea,
    insertCol: (c, v) => c.copyWith(
      bytea: Value(v),
    ),
    // Bytea is supported natively by drift
    customT: null,
  );
}

Future<void> _testColorEnum(TestsDatabase db, DbColor value) async {
  await _testCustomType<DbColor>(
    db,
    value: value,
    column: db.dataTypes.enum$,
    insertCol: (c, v) => c.copyWith(
      enum$: Value(v),
    ),
    customT: ElectricEnumTypes.color,
  );
}

Future<void> _testCustomType<DartT extends Object>(
  TestsDatabase db, {
  required DartT value,
  required GeneratedColumn<DartT> column,
  required DialectAwareSqlType<DartT>? customT,
  required DataTypesCompanion Function(DataTypesCompanion, DartT value)
      insertCol,
  DartT? expected,
}) async {
  final driftValue = await _insertAndFetchFromDataTypes(
    db,
    value: value,
    column: column,
    insertCol: insertCol,
    customT: customT,
  );

  _expectCorrectValue(
    db,
    columnDriftValue: driftValue,
    value: value,
    customT: customT,
    expected: expected,
  );
}

void _expectCorrectValue<DartT extends Object>(
  TestsDatabase db, {
  required DartT columnDriftValue,
  required DartT value,
  required DialectAwareSqlType<DartT>? customT,
  DartT? expected,
}) {
  if (value is double && value.isNaN) {
    expect(columnDriftValue, isNaN);
  } else {
    expect(columnDriftValue, expected ?? value);
  }

  // Quick sanity check for postgres: it should map to a TypedValue that our
  // wrappers would interpret correctly.
  if (customT != null) {
    final context = GenerationContext.fromDb(TestsDatabase.inMemoryPostgres());
    final mappedValue = customT.mapToSqlParameter(context, value);
    expect(mappedValue, isA<pg.TypedValue>());

    final typedValue = mappedValue as pg.TypedValue;
    final Object sqlValue;
    if (typedValue.type == pg.Type.unspecified) {
      final enumStr = typedValue.value! as String;
      sqlValue = _getUndecodedBytesForString(enumStr);
    } else {
      sqlValue = typedValue.value!;
    }

    final deserialized = customT.read(
      context.typeMapping,
      sqlValue,
    );

    if (value is double && value.isNaN) {
      expect(deserialized, isNaN);
    } else {
      expect(deserialized, value);
    }
  }
}

Future<DartT> _insertAndFetchFromDataTypes<DartT extends Object>(
  TestsDatabase db, {
  required DartT value,
  required GeneratedColumn<DartT> column,
  required DataTypesCompanion Function(DataTypesCompanion, DartT value)
      insertCol,
  required DialectAwareSqlType<DartT>? customT,
}) async {
  final baseCompanion = DataTypesCompanion.insert(
    id: 97,
  );

  final insertCompanion = insertCol(baseCompanion, value);

  await db.into(db.dataTypes).insert(insertCompanion);

  /* final allRows = await db.customSelect("select * from DataTypes").get();
  print("All rows:");
  for (final row in allRows) {
    print(row.data);
  } */

  final res = await (db.select(db.dataTypes)
        ..where((tbl) => column.equalsExp(Constant(value, customT))))
      .getSingle();
  expect(res.id, 97);

  final columns = res.toColumns(false);
  final columnDriftValue = (columns[column.name]! as Variable<DartT>).value!;
  return columnDriftValue;
}

Future<DartT> _insertAndFetchFromExtra<DartT extends Object>(
  TestsDatabase db, {
  required DartT value,
  required GeneratedColumn<DartT> column,
  required ExtraCompanion Function(ExtraCompanion, DartT value) insertCol,
  required DialectAwareSqlType<DartT>? customT,
}) async {
  final baseCompanion = ExtraCompanion.insert(
    id: 77,
  );

  final insertCompanion = insertCol(baseCompanion, value);

  await db.into(db.extra).insert(insertCompanion);

  /* final allRows = await db.customSelect("select * from Extra").get();
  print("All rows:");
  for (final row in allRows) {
    print(row.data);
  } */

  final res = await (db.select(db.extra)
        ..where((tbl) => column.equalsExp(Constant(value, customT))))
      .getSingle();
  expect(res.id, 77);

  final columns = res.toColumns(false);
  final columnDriftValue = (columns[column.name]! as Variable<DartT>).value!;
  return columnDriftValue;
}

Future<void> _testCustomTypeExtra<DartT extends Object>(
  TestsDatabase db, {
  required DartT value,
  required GeneratedColumn<DartT> column,
  required DialectAwareSqlType<DartT>? customT,
  required ExtraCompanion Function(ExtraCompanion, DartT value) insertCol,
  DartT? expected,
}) async {
  final driftValue = await _insertAndFetchFromExtra(
    db,
    value: value,
    column: column,
    insertCol: insertCol,
    customT: customT,
  );

  _expectCorrectValue(
    db,
    columnDriftValue: driftValue,
    value: value,
    customT: customT,
    expected: expected,
  );
}

pg.UndecodedBytes _getUndecodedBytesForString(String str) {
  const Encoding encoding = Utf8Codec();
  return pg.UndecodedBytes(
    typeOid: 12345,
    isBinary: true,
    bytes: Uint8List.fromList(encoding.encode(str)),
    encoding: encoding,
  );
}
