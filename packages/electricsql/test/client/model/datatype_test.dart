import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:test/test.dart';

import '../drift/database.dart';

void main() async {
  final db = TestsDatabase.memory();

  final electric = await electrify(
    dbName: 'test-db',
    db: db,
    migrations: [],
    config: ElectricConfig(auth: const AuthConfig(token: 'test-token')),
    opts: ElectrifyOptions(
      registry: MockRegistry(),
    ),
  );

  // Sync all shapes such that we don't get warnings on every query
  await electric.syncTables(['DataTypes']);

  setUp(() async {
    await db.customStatement('DROP TABLE IF EXISTS DataTypes');
    await db.customStatement(
      "CREATE TABLE DataTypes('id' int PRIMARY KEY, 'date' varchar, 'time' varchar, 'timetz' varchar, 'timestamp' varchar, 'timestamptz' varchar, 'bool' int, 'uuid' varchar, 'int2' int2, 'int4' int4, 'float8' real, 'relatedId' int);",
    );
  });

  /*
 * The tests below check that advanced data types
 * can be written into the DB, thereby, testing that
 * JS objects can be transformed to SQLite compatible values on writes
 * and then be converted back to JS objects on reads.
 */

  test('support date type', () async {
    const date = '2023-08-07';
    final d = DateTime.parse('$date 23:28:35.421');
    final res = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            date: Value(d),
          ),
        );

    expect(res.date, DateTime.parse(date));

    final fetchRes = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    expect(fetchRes?.date, DateTime.parse(date));
  });

  test('support time type', () async {
    final date = DateTime.parse('2023-08-07 18:28:35.421');

    final res = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            time: Value(date),
          ),
        );

    expect(res.time, DateTime.parse('1970-01-01 18:28:35.421'));

    final fetchRes = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    expect(fetchRes?.time, DateTime.parse('1970-01-01 18:28:35.421'));
  });

  test('support timetz type', () async {
    // Check that we store the time without taking into account timezones
    // such that upon reading we get the same time even if we are in a different time zone
    // test with 2 different time zones such that they cannot both coincide with the machine's timezone.
    final date1 = DateTime.parse('2023-08-07 18:28:35.421+02');
    final date2 = DateTime.parse('2023-08-07 18:28:35.421+03');

    final res1 = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            timetz: Value(date1),
          ),
        );

    final res2 = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(2),
            timetz: Value(date2),
          ),
        );

    expect(res1.timetz, DateTime.parse('1970-01-01 18:28:35.421+02'));
    expect(res2.timetz, DateTime.parse('1970-01-01 18:28:35.421+03'));

    final fetchRes1 = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    final fetchRes2 = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(2)))
        .getSingleOrNull();

    expect(fetchRes1?.timetz, DateTime.parse('1970-01-01 18:28:35.421+02'));
    expect(fetchRes2?.timetz, DateTime.parse('1970-01-01 18:28:35.421+03'));
  });

  test('support timestamp type', () async {
    final date = DateTime.parse('2023-08-07 18:28:35.421');

    final res = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            timestamp: Value(date),
          ),
        );

    expect(res.timestamp, DateTime.parse('2023-08-07 18:28:35.421'));

    final fetchRes = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    expect(fetchRes?.timestamp, DateTime.parse('2023-08-07 18:28:35.421'));
  });

  test('support timestamptz type', () async {
    // Check that we store the timestamp without taking into account timezones
    // such that upon reading we get the same timestamp even if we are in a different time zone
    // test with 2 different time zones such that they cannot both coincide with the machine's timezone.
    final date1 = DateTime.parse('2023-08-07 18:28:35.421+02');
    final date2 = DateTime.parse('2023-08-07 18:28:35.421+03');

    final res1 = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            timestamptz: Value(date1),
          ),
        );

    final res2 = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(2),
            timestamptz: Value(date2),
          ),
        );

    expect(res1.timestamptz, date1);
    expect(res2.timestamptz, date2);

    final fetchRes1 = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    final fetchRes2 = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(2)))
        .getSingleOrNull();

    expect(fetchRes1?.timestamptz, date1);
    expect(fetchRes2?.timestamptz, date2);
  });

  test('support null value for timestamptz type', () async {
    final res = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            timestamptz: const Value(null),
          ),
        );

    expect(res.id, 1);
    expect(res.timestamptz, null);

    final fetchRes = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingle();

    expect(fetchRes.id, 1);
    expect(fetchRes.timestamptz, null);
  });

// TODO(update): Tests

  test('support boolean type', () async {
    // Check that we can store booleans
    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            boolCol: const Value(true),
          ),
        );

    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(2),
            boolCol: const Value(false),
          ),
        );

    final rows = await db.select(db.dataTypes).get();

    expect(rows.any((r) => r.id == 1 && r.boolCol == true), isTrue);
    expect(rows.any((r) => r.id == 2 && r.boolCol == false), isTrue);
  });

  test('support null value for boolean type', () async {
    final res = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            boolCol: const Value(null),
          ),
        );

    expect(res.id, 1);
    expect(res.boolCol, null);

    final fetchRes = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    expect(fetchRes.boolCol, null);
  });

  test('support uuid type', () async {
    const uuid = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

    final res = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            uuid: const Value(uuid),
          ),
        );

    expect(res.id, 1);
    expect(res.uuid, uuid);

    final fetchRes = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    expect(fetchRes.uuid, uuid);

    // Check that it rejects invalid uuids
    await expectLater(
      () async => db.into(db.dataTypes).insertReturning(
            DataTypesCompanion.insert(
              id: const Value(1),
              uuid: const Value('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a111'),
            ),
          ),
      throwsA(
        isA<FormatException>().having(
          (p0) => p0.message,
          'message',
          'The provided UUID is invalid.',
        ),
      ),
    );
  });

  test('support null value for uuid type', () async {
    final res = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            uuid: const Value(null),
          ),
        );

    expect(res.id, 1);
    expect(res.uuid, null);

    final fetchRes = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    expect(fetchRes.uuid, null);
  });

  test('support int2 type', () async {
    const validInt1 = 32767;
    const invalidInt1 = 32768;

    const validInt2 = -32768;
    const invalidInt2 = -32769;

    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            int2: const Value(validInt1),
          ),
        );

    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(2),
            int2: const Value(validInt2),
          ),
        );

    // Check that it rejects invalid integers
    const invalidInts = [invalidInt1, invalidInt2];
    int id = 3;
    for (final invalidInt in invalidInts) {
      await expectLater(
        () async => db.into(db.dataTypes).insertReturning(
              DataTypesCompanion.insert(
                id: Value(id++),
                int2: Value(invalidInt),
              ),
            ),
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

  test('support null values for int2 type', () async {
    final res = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            int2: const Value(null),
          ),
        );

    expect(res.id, 1);
    expect(res.int2, null);

    final fetchRes = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    expect(fetchRes.int2, null);
  });

  test('support int4 type', () async {
    const validInt1 = 2147483647;
    const invalidInt1 = 2147483648;

    const validInt2 = -2147483648;
    const invalidInt2 = -2147483649;

    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            int4: const Value(validInt1),
          ),
        );

    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(2),
            int4: const Value(validInt2),
          ),
        );

    // Check that it rejects invalid integers
    const invalidInts = [invalidInt1, invalidInt2];
    int id = 3;
    for (final invalidInt in invalidInts) {
      await expectLater(
        () async => db.into(db.dataTypes).insertReturning(
              DataTypesCompanion.insert(
                id: Value(id++),
                int4: Value(invalidInt),
              ),
            ),
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

  test('support null values for int4 type', () async {
    final res = await db.into(db.dataTypes).insertReturning(
          DataTypesCompanion.insert(
            id: const Value(1),
            int4: const Value(null),
          ),
        );

    expect(res.id, 1);
    expect(res.int4, null);

    final fetchRes = await (db.select(db.dataTypes)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    expect(fetchRes.int4, null);
  });

/*
test.serial('support float8 type', async (t) => {
  const validFloat1 = 1.7976931348623157e308
  const validFloat2 = -1.7976931348623157e308
  const floats = [
    {
      id: 1,
      float8: validFloat1,
    },
    {
      id: 2,
      float8: validFloat2,
    },
    {
      id: 3,
      float8: +Infinity,
    },
    {
      id: 4,
      float8: -Infinity,
    },
    {
      id: 5,
      float8: NaN,
    },
  ]

  const res = await tbl.createMany({
    data: floats,
  })

  t.deepEqual(res, {
    count: 5,
  })

  // Check that we can read the floats back
  const fetchRes = await tbl.findMany({
    select: {
      id: true,
      float8: true,
    },
    orderBy: {
      id: 'asc',
    },
  })

  t.deepEqual(fetchRes, floats)
})


test.serial('support null values for float8 type', async (t) => {
  const expectedRes = {
    id: 1,
    float8: null,
  }

  const res = await tbl.create({
    data: {
      id: 1,
      float8: null,
    },
    select: {
      id: true,
      float8: true,
    },
  })

  t.deepEqual(res, expectedRes)

  const fetchRes = await tbl.findUnique({
    where: {
      id: 1,
    },
    select: {
      id: true,
      float8: true,
    },
  })

  t.deepEqual(fetchRes, expectedRes)
})

  */
}
