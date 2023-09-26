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
      "CREATE TABLE DataTypes('id' int PRIMARY KEY, 'date' varchar, 'time' varchar, 'timetz' varchar, 'timestamp' varchar, 'timestamptz' varchar, 'relatedId' int);",
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
}
