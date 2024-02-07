import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:electricsql/src/client/conversions/custom_types.dart';
import 'package:electricsql/src/util/converters/codecs/float4.dart';
import 'package:electricsql/src/util/converters/codecs/json.dart';
import 'package:test/test.dart';

import '../drift/client_test_util.dart';
import '../drift/database.dart';

void main() async {
  final db = TestsDatabase.memory();

  await electrifyTestDatabase(db);

  setUp(() async {
    await initClientTestsDb(db);
  });

  group('date', () {
    test('today', () async {
      final today = DateTime.now().copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );

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
      await _testTimestamp(db, date);
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
}

Future<void> _testDate(TestsDatabase db, DateTime value) async {
  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.date,
    insertCol: (c, v) => c.copyWith(
      date: Value(v),
    ),
    customT: ElectricTypes.date,
  );
}

Future<void> _testTime(TestsDatabase db, DateTime value) async {
  // Day and microseconds removed
  final expected = value.copyWith(
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

Future<void> _testTimestamp(TestsDatabase db, DateTime value) async {
  final expected = value.copyWith(
    microsecond: 0,
  );

  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.timestamp,
    insertCol: (c, v) => c.copyWith(
      timestamp: Value(v),
    ),
    customT: ElectricTypes.timestamp,
    expected: expected,
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
    column: db.dataTypes.boolCol,
    insertCol: (c, v) => c.copyWith(
      boolCol: Value(v),
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
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.int8BigInt,
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

Future<void> _testCustomType<DartT extends Object>(
  TestsDatabase db, {
  required DartT value,
  required GeneratedColumn<DartT> column,
  required DialectAwareSqlType<DartT>? customT,
  required DataTypesCompanion Function(DataTypesCompanion, DartT value)
      insertCol,
  DartT? expected,
}) async {
  final baseCompanion = DataTypesCompanion.insert(
    id: const Value(97),
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
  final columnDriftValue = (columns[column.name]! as Variable<DartT>).value;

  if (value is double && value.isNaN) {
    expect(columnDriftValue is double && columnDriftValue.isNaN, isTrue);
  } else {
    expect(columnDriftValue, expected ?? value);
  }
}
