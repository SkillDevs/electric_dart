import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:electricsql/src/client/conversions/custom_types.dart';
import 'package:electricsql/src/util/converters/codecs/float4.dart';
import 'package:electricsql/src/util/converters/codecs/json.dart';
import 'package:electricsql/src/util/converters/helpers.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../drift/database.dart';
import '../drift/generated/electric/drift_schema.dart';

@isTestGroup
void dataTypeTests({
  required TestsDatabase Function() getDb,
  bool isPostgres = false,
}) {
  late TestsDatabase db;

  setUp(() async {
    db = getDb();
  });

  group('date', () {
    group('local', () {
      test('regular', () async {
        await _testDate(
          db,
          DateTime.parse('2023-08-07 18:28:35.421'),
          expected: DateTime.utc(2023, 8, 7),
        );
      });

      test('edge 1', () async {
        // 2000-01-15 00:05:00
        await _testDate(
          db,
          DateTime(2000, 1, 15, 0, 5),
          expected: DateTime.utc(2000, 1, 15),
        );
      });

      test('edge 2', () async {
        // 2000-01-15 23:55:00
        await _testDate(
          db,
          DateTime(2000, 1, 15, 23, 55),
          expected: DateTime.utc(2000, 1, 15),
        );
      });
    });

    group('utc', () {
      test('regular', () async {
        // 2023-08-07 18:28:35.421956+00
        await _testDate(
          db,
          DateTime.utc(2023, 8, 7, 18, 28, 35, 421, 956),
          expected: DateTime.utc(2023, 8, 7),
        );
      });

      test('edge 1', () async {
        // 2000-01-15 00:05:00
        await _testDate(
          db,
          DateTime.utc(2000, 1, 15, 0, 5),
          expected: DateTime.utc(2000, 1, 15),
        );
      });

      test('edge 2', () async {
        // 2000-01-15 23:55:00
        await _testDate(
          db,
          DateTime.utc(2000, 1, 15, 23, 55),
          expected: DateTime.utc(2000, 1, 15),
        );
      });
    });

    test('min', () async {
      await _testDate(db, DateTime.utc(1));
    });

    test('max', () async {
      await _testDate(db, DateTime.utc(9999, 12, 31));
    });
  });

  group('time', () {
    test('now', () async {
      final now = DateTime.now();
      await _testTime(db, now);
    });

    test('utc', () async {
      final now = DateTime.now().toUtc();
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

  // The postgres library does not support the timetz type as it's not
  // recommended to use it.
  // https://wiki.postgresql.org/wiki/Don't_Do_This#Don.27t_use_timetz
  if (!isPostgres) {
    group(
      'timetz',
      () {
        test('regular 1', () async {
          final date = DateTime.parse('2023-08-07 18:28:35.421+03');
          await _testTimeTZ(db, date);
        });

        test('regular 2', () async {
          final date = DateTime.parse('2023-08-07 18:28:35.421+02');
          await _testTimeTZ(db, date);
        });

        test('insert and query', () async {
          // Check that we store the time without taking into account timezones
          // such that upon reading we get the same time even if we are in a different time zone
          // test with 2 different time zones such that they cannot both coincide with the machine's timezone.
          final date1 = DateTime.parse('2023-08-07 18:28:35.421+02');
          final date2 = DateTime.parse('2023-08-07 18:28:35.421+03');

          final res1 = await db.into(db.dataTypes).insertReturning(
                DataTypesCompanion.insert(
                  id: 1,
                  timetz: Value(date1),
                ),
              );

          final res2 = await db.into(db.dataTypes).insertReturning(
                DataTypesCompanion.insert(
                  id: 2,
                  timetz: Value(date2),
                ),
              );

          final expectedDate1 = DateTime.parse('1970-01-01 18:28:35.421+02');

          expect(res1.timetz, expectedDate1);
          expect(res2.timetz, DateTime.parse('1970-01-01 18:28:35.421+03'));

          final fetchRes1 = await (db.select(db.dataTypes)
                ..where((t) => t.id.equals(1)))
              .getSingleOrNull();

          final fetchRes2 = await (db.select(db.dataTypes)
                ..where((t) => t.id.equals(2)))
              .getSingleOrNull();

          expect(
            fetchRes1?.timetz,
            DateTime.parse('1970-01-01 18:28:35.421+02'),
          );
          expect(
            fetchRes2?.timetz,
            DateTime.parse('1970-01-01 18:28:35.421+03'),
          );
        });
      },
    );
  }

  group('timestamp', () {
    test('local', () async {
      await _testTimestamp(
        db,
        DateTime.parse('2023-08-07 18:28:35.421956'),
        expected: DateTime.utc(2023, 8, 7, 18, 28, 35, 421, 956),
      );
    });

    test('utc', () async {
      await _testTimestamp(
        db,
        // 2023-08-07 18:28:35.421956+00
        DateTime.utc(2023, 8, 7, 18, 28, 35, 421, 956),
      );
    });

    test('min', () async {
      await _testTimestamp(db, DateTime.utc(1));
    });

    test('max', () async {
      await _testTimestamp(
        db,
        DateTime.utc(9999, 12, 31, 23, 59, 59, 999, 999),
      );
    });
  });

  group('timestamptz', () {
    test('now', () async {
      final now = DateTime.now();
      await _testTimestampTZ(db, now);
    });

    test('regular 1', () async {
      final date = DateTime.parse('2023-08-07 18:28:35.421+03');
      await _testTimestampTZ(db, date);
    });

    test('regular 2', () async {
      final date = DateTime.parse('2023-08-07 18:28:35.421+02');
      await _testTimestampTZ(db, date);
    });

    test('regular 3', () async {
      final date = DateTime.parse('2023-08-07 18:28:35');
      await _testTimestampTZ(db, date);
    });

    test('insert and query', () async {
      // Check that we store the timestamp without taking into account timezones
      // such that upon reading we get the same timestamp even if we are in a different time zone
      // test with 2 different time zones such that they cannot both coincide with the machine's timezone.
      final date1 = DateTime.parse('2023-08-07 18:28:35.421+02');
      final date2 = DateTime.parse('2023-08-07 18:28:35.421+03');

      final res1 = await db.into(db.dataTypes).insertReturning(
            DataTypesCompanion.insert(
              id: 1,
              timestamptz: Value(date1),
            ),
          );

      final res2 = await db.into(db.dataTypes).insertReturning(
            DataTypesCompanion.insert(
              id: 2,
              timestamptz: Value(date2),
            ),
          );

      expect(res1.timestamptz, date1);
      expect(res2.timestamptz, date2);

      expect(res1.timestamptz!.isUtc, isTrue);
      expect(res2.timestamptz!.isUtc, isTrue);

      final fetchRes1 = await (db.select(db.dataTypes)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();

      final fetchRes2 = await (db.select(db.dataTypes)
            ..where((t) => t.id.equals(2)))
          .getSingleOrNull();

      expect(fetchRes1?.timestamptz, date1);
      expect(fetchRes2?.timestamptz, date2);
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

    test('invalid', () async {
      // Check that it rejects invalid uuids
      await expectLater(
        () async => _testUUID(db, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a111'),
        throwsA(
          isA<FormatException>().having(
            (p0) => p0.message,
            'message',
            'The provided UUID is invalid.',
          ),
        ),
      );
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

    test('invalid', () async {
      // Check that it rejects invalid integers
      const invalidInt1 = 32768;
      const invalidInt2 = -32769;

      const invalidInts = [invalidInt1, invalidInt2];
      for (final invalidInt in invalidInts) {
        await expectLater(
          () async => _testInt2(db, invalidInt),
          throwsA(
            isA<RangeError>().having(
              (p0) => p0.toString(),
              'error',
              contains(
                'Invalid value: Not in inclusive range -32768..32767: $invalidInt',
              ),
            ),
          ),
        );
      }
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

    test('invalid', () async {
      // Check that it rejects invalid integers
      const invalidInt1 = 2147483648;
      const invalidInt2 = -2147483649;

      const invalidInts = [invalidInt1, invalidInt2];
      for (final invalidInt in invalidInts) {
        await expectLater(
          () async => _testInt4(db, invalidInt),
          throwsA(
            isA<RangeError>().having(
              (p0) => p0.toString(),
              'error',
              contains(
                'Invalid value: Not in inclusive range -2147483648..2147483647: $invalidInt',
              ),
            ),
          ),
        );
      }
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

  // Postgres supports int64 without using the BigInt type
  if (!isPostgres) {
    group(
      'int8 bigint',
      () {
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
          final invalidBigInts = [
            BigInt.parse('9223372036854775808'),
            BigInt.parse('-9223372036854775809'),
          ];
          for (final invalidBigInt in invalidBigInts) {
            await expectLater(
              () async => _testInt8BigInt(db, invalidBigInt),
              throwsA(
                isA<Exception>().having(
                  (p0) => p0.toString(),
                  'error',
                  contains(
                    'BigInt value exceeds the range of 64 bits',
                  ),
                ),
              ),
            );
          }
        });
      },
    );
  }

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
    test('complex', () async {
      await _testJson(db, {
        'a': 1,
        'b': true,
        'c': {'d': 'nested'},
        'e': [1, 2, 3],
        'f': null,
      });
    });

    test(
      'null',
      () async {
        // final rwos = await db.customSelect('''SELECT null as c1, 'null'::jsonb as c2, '"null"'::jsonb as c3''').get();
        // for (final row in rwos) {
        //   print(row.data.map((key, value) => MapEntry(key, '$value ${value.runtimeType}')));
        // }

        if (isPostgres) {
          // Currently can't store top-level JSON null values when using PG
          // they are automatically transformed to DB NULL
          await _testJson(
            db,
            kJsonNull,
            expected: null,
            forceProvidedExpected: true,
          );
        } else {
          await _testJson(db, kJsonNull);
        }
      },
    );

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
  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.date,
    insertCol: (c, v) => c.copyWith(
      date: Value(v),
    ),
    customT: ElectricTypes.date,
    expected: expected,
    alternativeInputs: [
      value.asLocal(),
      value.asUtc(),
    ],
  );
}

Future<void> _testTime(TestsDatabase db, DateTime value) async {
  // Day removed
  DateTime expected = value.asUtc().copyWith(
        year: 1970,
        month: 1,
        day: 1,
      );

  if (db.typeMapping.dialect == SqlDialect.sqlite) {
    expected = expected.copyWith(microsecond: 0);
  }

  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.time,
    insertCol: (c, v) => c.copyWith(
      time: Value(v),
    ),
    customT: ElectricTypes.time,
    expected: expected,
    alternativeInputs: [
      value.asLocal(),
      value.asUtc(),
    ],
  );
}

Future<void> _testTimeTZ(TestsDatabase db, DateTime value) async {
  // Day removed
  DateTime expected = value
      .copyWith(
        year: 1970,
        month: 1,
        day: 1,
      )
      .toUtc();

  if (db.typeMapping.dialect == SqlDialect.sqlite) {
    expected = expected.copyWith(microsecond: 0);
  }

  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.timetz,
    insertCol: (c, v) => c.copyWith(
      timetz: Value(v),
    ),
    customT: ElectricTypes.timeTZ,
    expected: expected,
    alternativeInputs: [
      value.toLocal(),
      value.toUtc(),
    ],
  );
}

Future<void> _testTimestamp(
  TestsDatabase db,
  DateTime value, {
  DateTime? expected,
}) async {
  DateTime expectedDate = expected ?? value;

  if (db.typeMapping.dialect == SqlDialect.sqlite) {
    expectedDate = expectedDate.copyWith(microsecond: 0);
  }

  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.timestamp,
    insertCol: (c, v) => c.copyWith(
      timestamp: Value(v),
    ),
    customT: ElectricTypes.timestamp,
    expected: expectedDate,
    alternativeInputs: [
      value.asLocal(),
      value.asUtc(),
    ],
  );
}

Future<void> _testTimestampTZ(TestsDatabase db, DateTime value) async {
  DateTime expected = value.toUtc();

  if (db.typeMapping.dialect == SqlDialect.sqlite) {
    expected = expected.copyWith(microsecond: 0);
  }

  await _testCustomType<DateTime>(
    db,
    value: value,
    column: db.dataTypes.timestamptz,
    insertCol: (c, v) => c.copyWith(
      timestamptz: Value(v),
    ),
    customT: ElectricTypes.timestampTZ,
    expected: expected,
    alternativeInputs: [
      value.toLocal(),
      value.toUtc(),
    ],
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

Future<void> _testJson(
  TestsDatabase db,
  Object value, {
  Object? expected,
  bool forceProvidedExpected = false,
}) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.json,
    insertCol: (c, v) => c.copyWith(
      json: Value(v),
    ),
    customT: ElectricTypes.jsonb,
    expected: expected,
    forceProvidedExpected: forceProvidedExpected,
  );

  // await _testCustomType(
  //   db,
  //   value: value,
  //   column: db.dataTypes.json,
  //   insertCol: (c, v) => c.copyWith(
  //     json: Value(v),
  //   ),
  //   customT: ElectricTypes.json,
  // );
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
  List<DartT>? alternativeInputs,
  bool forceProvidedExpected = false,
}) async {
  final effectiveExpected = _getEffectiveExpected(
    value: value,
    expected: expected,
    forceProvidedExpected: forceProvidedExpected,
  );

  final driftValue = await _insertAndFetchFromDataTypes(
    db,
    value: value,
    column: column,
    insertCol: insertCol,
    customT: customT,
    alternativeInputs: alternativeInputs,
    expected: effectiveExpected,
  );

  _expectCorrectValue<DartT>(
    db,
    columnDriftValue: driftValue,
    value: value,
    customT: customT,
    expected: effectiveExpected,
  );
}

void _expectCorrectValue<DartT extends Object>(
  TestsDatabase db, {
  required DartT? columnDriftValue,
  required DartT value,
  required DialectAwareSqlType<DartT>? customT,
  required DartT? expected,
}) {
  if (value is double && value.isNaN) {
    expect(columnDriftValue, isNaN);
  } else {
    expect(columnDriftValue, expected);
  }
}

DartT? _getEffectiveExpected<DartT extends Object>({
  required DartT value,
  required DartT? expected,
  required bool forceProvidedExpected,
}) {
  final DartT? effectiveExpected;
  if (forceProvidedExpected) {
    effectiveExpected = expected;
  } else {
    effectiveExpected = expected ?? value;
  }
  return effectiveExpected;
}

Future<DartT?> _insertAndFetchFromDataTypes<DartT extends Object>(
  TestsDatabase db, {
  required DartT value,
  required GeneratedColumn<DartT> column,
  required DataTypesCompanion Function(DataTypesCompanion, DartT value)
      insertCol,
  required DialectAwareSqlType<DartT>? customT,
  List<DartT>? alternativeInputs,
  required DartT? expected,
}) async {
  final baseCompanion = DataTypesCompanion.insert(
    id: 97,
  );

  final insertCompanion = insertCol(baseCompanion, value);

  await db.into(db.dataTypes).insert(insertCompanion);

  /* final allRows =
      await db.customSelect('select ${column.name} from "DataTypes"').get();
  print("All rows:");
  for (final row in allRows) {
    print(row.data
        .map((key, value) => MapEntry(key, '$value ${value.runtimeType}')));
  }
  */
  final res = await (db.select(db.dataTypes)
        ..where((tbl) => column.equalsExp(Constant(value, customT))))
      .getSingle();
  expect(res.id, 97);

  // Search by alternative inputs that should yield the same row result
  // i.e. DateTimes in Local and UTC
  if (alternativeInputs != null) {
    for (final altValue in alternativeInputs) {
      final altRes = await (db.select(db.dataTypes)
            ..where((tbl) => column.equalsExp(Constant(altValue, customT))))
          .getSingle();
      expect(altRes.id, 97);
    }
  }

  final columns = res.toColumns(false);
  final columnDriftValue = (columns[column.name]! as Variable<DartT>).value;

  if (expected != null) {
    expect(columnDriftValue != null, isTrue);
  }
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
    id: const Value(77),
  );

  final insertCompanion = insertCol(baseCompanion, value);

  await db.into(db.extra).insert(insertCompanion);

  /* final allRows = await db.customSelect("select * from Extra").get();
  print("All rows:");
  for (final row in allRows) {
    print(row.data);
  } */

  final res = await (db.select(db.extra)..where((tbl) => column.equals(value)))
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
  final effectiveExpected = _getEffectiveExpected(
    value: value,
    expected: expected,
    forceProvidedExpected: false,
  );

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
    expected: effectiveExpected,
  );
}
