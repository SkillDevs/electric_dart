import 'package:drift/drift.dart';
import 'package:electricsql/src/client/conversions/custom_types.dart';
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

  group('bool', () {
    test('true', () async {
      await _testBool(db, true);
    });

    test('false', () async {
      await _testBool(db, false);
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

Future<void> _testBool(TestsDatabase db, bool value) async {
  await _testCustomType(
    db,
    value: value,
    column: db.dataTypes.boolCol,
    insertCol: (c, v) => c.copyWith(
      boolCol: Value(v),
    ),
    // TODO(update): Use customtype for bool??
    customT: null,
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

Future<void> _testCustomType<DartT extends Object>(
  TestsDatabase db, {
  required DartT value,
  required GeneratedColumn<DartT> column,
  required CustomSqlType<DartT>? customT,
  required DataTypesCompanion Function(DataTypesCompanion, DartT value)
      insertCol,
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
    expect(columnDriftValue, value);
  }
}
