import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/drivers/drift/drift.dart';
import 'package:electricsql/src/satellite/mock.dart';

import 'database.dart';

Future<ElectricClient<TestsDatabase>> electrifyTestDatabase(
  TestsDatabase db,
) async {
  final electric = await electrify(
    dbName: 'test-db',
    db: db,
    migrations: const ElectricMigrations(
      sqliteMigrations: [],
      pgMigrations: [],
    ),
    config: ElectricConfig(),
    opts: ElectrifyOptions(
      registry: MockRegistry(),
    ),
  );

  // Sync all shapes such that we don't get warnings on every query
  await electric.syncTable(db.dataTypes);

  return electric;
}

Future<void> initClientTestsDb(TestsDatabase db) async {
  final dialect = db.typeMapping.dialect;
  final dateType = dialect == SqlDialect.postgres ? 'date' : 'text';
  final timeType = dialect == SqlDialect.postgres ? 'time' : 'text';
  final timeTzType = dialect == SqlDialect.postgres ? 'timetz' : 'text';
  final timestampType = dialect == SqlDialect.postgres ? 'timestamp' : 'text';
  final timestampTzType =
      dialect == SqlDialect.postgres ? 'timestamptz' : 'text';
  final jsonType = dialect == SqlDialect.postgres ? 'jsonb' : 'text';
  final float8Type = dialect == SqlDialect.postgres ? 'float8' : 'real';
  final int8Type = dialect == SqlDialect.postgres ? 'int8' : 'integer';

  await db.customStatement('DROP TABLE IF EXISTS "DataTypes"');
  await db.customStatement(
    'CREATE TABLE "DataTypes"("id" int PRIMARY KEY, "date" $dateType, "time" $timeType, "timetz" $timeTzType, "timestamp" $timestampType, '
    '"timestamptz" $timestampTzType, "bool" ${dialect.booleanType}, "uuid" varchar, "int2" int2, "int4" int4, "int8" $int8Type, "int8_big_int" $int8Type, '
    '"float4" real, "float8" $float8Type, "json" $jsonType, "enum" varchar, "bytea" ${dialect.blobType}, "relatedId" int);',
  );

  await db.customStatement('DROP TABLE IF EXISTS "Extra"');
  await db.customStatement(
    'CREATE TABLE "Extra"("id" int PRIMARY KEY, "int8_big_int" integer);',
  );
}
