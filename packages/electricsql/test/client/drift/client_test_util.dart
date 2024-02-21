import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/drivers/drift/drift.dart';
import 'package:electricsql/src/satellite/mock.dart';

import 'database.dart';

Future<DriftElectricClient<DB>>
    electrifyTestDatabase<DB extends DatabaseConnectionUser>(DB db) async {
  final electric = await electrify(
    dbName: 'test-db',
    db: db,
    migrations: [],
    config: ElectricConfig(),
    opts: ElectrifyOptions(
      registry: MockRegistry(),
    ),
  );

  // Sync all shapes such that we don't get warnings on every query
  await electric.syncTables(['DataTypes']);

  return electric;
}

Future<void> initClientTestsDb(TestsDatabase db) async {
  await db.customStatement('DROP TABLE IF EXISTS DataTypes');
  await db.customStatement(
    "CREATE TABLE DataTypes('id' int PRIMARY KEY, 'date' varchar, 'time' varchar, 'timetz' varchar, 'timestamp' varchar, "
    "'timestamptz' varchar, 'bool' int, 'uuid' varchar, 'int2' int2, 'int4' int4, 'int8' integer, 'int8_big_int' integer, "
    "'float4' real, 'float8' real, 'json' varchar, 'enum' varchar, 'relatedId' int);",
  );
}
