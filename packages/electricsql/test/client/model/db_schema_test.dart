import 'package:electricsql/src/client/conversions/types.dart';
import 'package:test/test.dart';

import '../drift/client_test_util.dart';
import '../drift/database.dart';

void main() async {
  final db = TestsDatabase.memory();

  final client = await electrifyTestDatabase(db);

  final dbDescription = client.dbDescription;

  setUp(() async {
    await initClientTestsDb(db);
  });

  test('pg types extracted from drift', () async {
    final dataTypesFields = dbDescription.getFields('DataTypes');

    final numCols = db.dataTypes.$columns.length;
    // Don't count the enum column
    expect(dataTypesFields.length, numCols - 1);

    expect(dataTypesFields, {
      'id': PgType.integer,
      'date': PgType.date,
      'time': PgType.time,
      'timetz': PgType.timeTz,
      'timestamp': PgType.timestamp,
      'timestamptz': PgType.timestampTz,
      'bool': PgType.bool,
      'uuid': PgType.uuid,
      'int2': PgType.int2,
      'int4': PgType.int4,
      'int8': PgType.int8,
      'int8_big_int': PgType.int8,
      'float4': PgType.float4,
      'float8': PgType.float8,
      'json': PgType.json,
      'relatedId': PgType.integer,
    });

    final postsFields = dbDescription.getFields('Post');
    expect(postsFields, {
      'id': PgType.integer,
      'title': PgType.text,
      'contents': PgType.text,
      'nbr': PgType.integer,
      'authorId': PgType.integer,
    });
  });
}
