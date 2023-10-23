import 'package:drift/drift.dart';
import 'package:test/test.dart';

import '../drift/client_test_util.dart';
import '../drift/database.dart';

void main() async {
  final db = TestsDatabase.memory();

  await electrifyTestDatabase(db);

  setUp(() async {
    await initClientTestsDb(db);
  });

  /*
 * The tests below check that JS values are correctly converted to SQLite values
 * based on the original PG type of that value.
 * e.g. PG `timestamptz` values are represented as `Date` objects in JS
 *      and are converted to ISO-8601 strings that are stored in SQLite.
 */

  test('date is converted correctly to SQLite', () async {
    const date = '2023-09-13';
    final d = DateTime.parse('${date}T23:33:04.271');
    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            date: Value(d),
          ),
        );

    final rawRes = await db.customSelect(
      'SELECT date FROM DataTypes WHERE id = ?',
      variables: [const Variable(1)],
    ).get();
    expect(rawRes[0].read<String>('date'), date);
  });

  test('time is converted correctly to SQLite', () async {
    // Check that we store the time without taking into account timezones
    // test with 2 different time zones such that they cannot both coincide with the machine's timezone
    final date = DateTime.parse('2023-08-07 18:28:35.421');
    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            time: Value(date),
          ),
        );

    final rawRes = await db.customSelect(
      'SELECT time FROM DataTypes WHERE id = ?',
      variables: [const Variable(1)],
    ).get();
    expect(rawRes[0].read<String>('time'), '18:28:35.421');
  });

  test('timetz is converted correctly to SQLite', () async {
    final date1 = DateTime.parse('2023-08-07 18:28:35.421+02');
    final date2 = DateTime.parse('2023-08-07 18:28:35.421+03');

    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            timetz: Value(date1),
          ),
        );
    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(2),
            timetz: Value(date2),
          ),
        );

    final rawRes1 = await db.customSelect(
      'SELECT timetz FROM DataTypes WHERE id = ?',
      variables: [const Variable(1)],
    ).get();
    expect(
      rawRes1[0].read<String>('timetz'),
      '16:28:35.421',
    ); // time must have been converted to UTC time

    final rawRes2 = await db.customSelect(
      'SELECT timetz FROM DataTypes WHERE id = ?',
      variables: [const Variable(2)],
    ).get();
    expect(rawRes2[0].read<String>('timetz'), '15:28:35.421');
  });

  test('timestamp is converted correctly to SQLite', () async {
    final date = DateTime.parse('2023-08-07 18:28:35.421');
    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            timestamp: Value(date),
          ),
        );

    final rawRes = await db.customSelect(
      'SELECT timestamp FROM DataTypes WHERE id = ?',
      variables: [const Variable(1)],
    ).get();
    expect(
      rawRes[0].read<String>('timestamp'),
      '2023-08-07 18:28:35.421',
    ); // time must have been converted to UTC time
  });

  test('timestamptz is converted correctly to SQLite', () async {
    final date1 = DateTime.parse('2023-08-07 18:28:35.421+02');
    final date2 = DateTime.parse('2023-08-07 18:28:35.421+03');
    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            timestamptz: Value(date1),
          ),
        );
    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(2),
            timestamptz: Value(date2),
          ),
        );

    final rawRes1 = await db.customSelect(
      'SELECT timestamptz FROM DataTypes WHERE id = ?',
      variables: [const Variable(1)],
    ).get();
    expect(
      rawRes1[0].read<String>('timestamptz'),
      '2023-08-07 16:28:35.421Z',
    ); // timestamp must have been converted to UTC timestamp

    final rawRes2 = await db.customSelect(
      'SELECT timestamptz FROM DataTypes WHERE id = ?',
      variables: [const Variable(2)],
    ).get();
    expect(rawRes2[0].read<String>('timestamptz'), '2023-08-07 15:28:35.421Z');
  });
}
