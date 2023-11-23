import 'package:drift/drift.dart';
import 'package:electricsql/src/util/converters/helpers.dart';
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

    await db.dataTypes.insertAll([
      DataTypesCompanion.insert(
        id: const Value(1),
        timetz: Value(date1),
      ),
      DataTypesCompanion.insert(
        id: const Value(2),
        timetz: Value(date2),
      ),
    ]);

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
    expect(date.isUtc, isFalse);

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

  test('timestamp is converted correctly to SQLite - input date utc', () async {
    // 2023-08-07 18:28:35.421 UTC
    final dateUTC = DateTime.utc(2023, 8, 7, 18, 28, 35, 421);
    expect(dateUTC.isUtc, isTrue);

    // The local date is stored as String, without the T and Z characters
    final localDate = dateUTC.toLocal();
    final expectedLocalStr = DateTime.utc(
      localDate.year,
      localDate.month,
      localDate.day,
      localDate.hour,
      localDate.minute,
      localDate.second,
      localDate.millisecond,
      localDate.microsecond,
    ).toISOStringUTC().replaceAll('T', ' ').replaceAll('Z', '');

    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            timestamp: Value(dateUTC),
          ),
        );

    final rawRes = await db.customSelect(
      'SELECT timestamp FROM DataTypes WHERE id = ?',
      variables: [const Variable(1)],
    ).get();

    expect(
      rawRes[0].read<String>('timestamp'),
      expectedLocalStr,
    );
  });

  test('timestamptz is converted correctly to SQLite', () async {
    final date1 = DateTime.parse('2023-08-07 18:28:35.421+02');
    final date2 = DateTime.parse('2023-08-07 18:28:35.421+03');

    await db.dataTypes.insertAll([
      DataTypesCompanion.insert(
        id: const Value(1),
        timestamptz: Value(date1),
      ),
      DataTypesCompanion.insert(
        id: const Value(2),
        timestamptz: Value(date2),
      ),
    ]);

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

  test('booleans are converted correctly to SQLite', () async {
    await db.dataTypes.insertAll([
      DataTypesCompanion.insert(
        id: const Value(1),
        boolCol: const Value(true),
      ),
      DataTypesCompanion.insert(
        id: const Value(2),
        boolCol: const Value(false),
      ),
    ]);

    final rawRes = await db.customSelect(
      'SELECT id, bool FROM DataTypes ORDER BY id ASC',
      variables: [],
    ).get();

    final row1 = rawRes[0].data;
    expect(row1['id'], 1);
    expect(row1['bool'], 1);

    final row2 = rawRes[1].data;
    expect(row2['id'], 2);
    expect(row2['bool'], 0);
  });

  test('floats are converted correctly to SQLite', () async {
    final List<(int id, double value)> values = [
      (1, 1.234),
      (2, double.nan),
      (3, double.infinity),
      (4, double.negativeInfinity),
    ];

    for (final entry in values) {
      final (id, value) = entry;
      await db.into(db.dataTypes).insert(
            DataTypesCompanion.insert(
              id: Value(id),
              float8: Value(value),
            ),
          );
    }

    final rawRes = await db.customSelect(
      'SELECT id, float8 FROM DataTypes ORDER BY id ASC',
      variables: [],
    ).get();

    final List<(int id, Object value)> expected = [
      (1, 1.234),
      (2, 'NaN'),
      (3, double.infinity),
      (4, double.negativeInfinity),
    ];

    final List<(int id, Object value)> rowsRecords = rawRes.map((row) {
      final data = row.data;
      final id = data['id'] as int;
      final Object value = data['float8'] as Object;
      return (id, value);
    }).toList();

    expect(rowsRecords, expected);
  });

  test('Int8s are converted correctly to SQLite', () async {
    const int8 = 9223372036854775807;

    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            int8: const Value(int8),
          ),
        );

    final rawRes = await db.customSelect(
      'SELECT id, int8 FROM DataTypes WHERE id = ?',
      variables: [const Variable(1)],
    ).get();

    final row = rawRes[0].data;
    expect(row['id'], 1);
    expect(row['int8'], int8);
  });

  test('BigInts are converted correctly to SQLite', () async {
    final bigInt = BigInt.parse('9223372036854775807');

    await db.into(db.dataTypes).insert(
          DataTypesCompanion.insert(
            id: const Value(1),
            int8BigInt: Value(bigInt),
          ),
        );

    final rawRes = await db.customSelect(
      'SELECT id, int8_big_int FROM DataTypes WHERE id = ?',
      variables: [const Variable(1)],
    ).get();

    // because we are executing a raw query,
    // the returned BigInt for the `id`
    // is not converted into a regular number
    final row = rawRes[0].data;
    expect(row['id'], 1);
    expect((row['int8_big_int'] as int).toString(), bigInt.toString());
  });

  test('drift files serialization/deserialization', () async {
    final date = DateTime.parse('2023-08-07 18:28:35.421+02');

    final res = await db.tableFromDriftFile.insertReturning(
      TableFromDriftFileCompanion.insert(
        id: 'abc',
        timestamp: date,
      ),
    );

    expect(res.timestamp, date);

    final rawRes1 = await db.customSelect(
      'SELECT timestamp FROM table_from_drift_file WHERE id = ?',
      variables: [const Variable('abc')],
    ).get();
    expect(
      rawRes1[0].read<String>('timestamp'),
      '2023-08-07 16:28:35.421Z',
    );
  });
}
