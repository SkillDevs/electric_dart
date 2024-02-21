import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnectionUser;
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/client/model/client.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/client/model/shapes.dart';
import 'package:electricsql/src/drivers/drift/drift_adapter.dart';
import 'package:electricsql/src/drivers/sqlite3/sqlite3_adapter.dart';
import 'package:electricsql/src/migrators/schema.dart';
import 'package:electricsql/src/migrators/triggers.dart';
import 'package:electricsql/src/notifiers/index.dart';
import 'package:electricsql/src/notifiers/mock.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart';

import '../support/migrations.dart';
import '../support/satellite_helpers.dart';
import '../util/io.dart';
import '../util/sqlite.dart';

// Speed up the intervals for testing.
final opts = kSatelliteDefaults.copyWith(
  minSnapshotWindow: const Duration(milliseconds: 40),
  pollingInterval: const Duration(milliseconds: 200),
);

DBSchema kTestDbDescription = DBSchemaRaw(
  fields: {
    'child': {
      'id': PgType.integer,
      'parent': PgType.integer,
    },
    'parent': {
      'id': PgType.integer,
      'value': PgType.text,
      'other': PgType.integer,
    },
    'another': {
      'id': PgType.integer,
    },
  },
  migrations: [],
);

Map<String, Relation> kTestRelations = {
  'child': Relation(
    id: 0,
    schema: 'public',
    table: 'child',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'INTEGER',
        isNullable: false,
        primaryKey: true,
      ),
      RelationColumn(
        name: 'parent',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: false,
      ),
    ],
  ),
  'parent': Relation(
    id: 1,
    schema: 'public',
    table: 'parent',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'INTEGER',
        isNullable: false,
        primaryKey: true,
      ),
      RelationColumn(
        name: 'value',
        type: 'TEXT',
        isNullable: true,
        primaryKey: false,
      ),
      RelationColumn(
        name: 'other',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: false,
      ),
    ],
  ),
  'another': Relation(
    id: 2,
    schema: 'public',
    table: 'another',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'INTEGER',
        isNullable: false,
        primaryKey: true,
      ),
    ],
  ),
  'mergeTable': Relation(
    id: 3,
    schema: 'public',
    table: 'mergeTable',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'INTEGER',
        isNullable: false,
        primaryKey: true,
      ),
      RelationColumn(
        name: 'real',
        type: 'REAL',
        isNullable: true,
        primaryKey: false,
      ),
      RelationColumn(
        name: 'int8',
        type: 'INT8',
        isNullable: true,
        primaryKey: false,
      ),
      RelationColumn(
        name: 'bigint',
        type: 'BIGINT',
        isNullable: true,
        primaryKey: false,
      ),
    ],
  ),
  'personTable': Relation(
    id: 4,
    schema: 'public',
    table: 'personTable',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'REAL',
        isNullable: false,
        primaryKey: true,
      ),
      RelationColumn(
        name: 'name',
        type: 'TEXT',
        isNullable: true,
        primaryKey: false,
      ),
      RelationColumn(
        name: 'age',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: false,
      ),
      RelationColumn(
        name: 'bmi',
        type: 'REAL',
        isNullable: true,
        primaryKey: false,
      ),
      RelationColumn(
        name: 'int8',
        type: 'INT8',
        isNullable: true,
        primaryKey: false,
      ),
    ],
  ),
  'bigIntTable': Relation(
    id: 5,
    schema: 'public',
    table: 'bigIntTable',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'value',
        type: 'INT8',
        isNullable: false,
        primaryKey: true,
      ),
    ],
  ),
};

Future<SatelliteTestContext> makeContext({
  SatelliteOpts? options,
}) async {
  await Directory('.tmp').create(recursive: true);

  final dbName = '.tmp/test-${randomValue()}.db';
  final db = openSqliteDb(dbName);

  final adapter = SqliteAdapter(db);
  // Electric depends on Foregin keys being ON and tests do not electrify
  // So we call it explicitly
  await adapter.run(Statement('PRAGMA foreign_keys = ON'));

  final migrator =
      BundleMigrator(adapter: adapter, migrations: kTestMigrations);
  final notifier = MockNotifier(dbName);
  final client = MockSatelliteClient();
  final satellite = SatelliteProcess(
    dbName: dbName,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    client: client,
    opts: options ?? opts,
  );

  final tableInfo = initTableInfo();
  final timestamp = DateTime.now();

  const authConfig = AuthConfig(clientId: '');
  final token = insecureAuthToken({'sub': 'test-user'});

  return SatelliteTestContext(
    dbName: dbName,
    db: db,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    client: client,
    satellite: satellite,
    tableInfo: tableInfo,
    timestamp: timestamp,
    authConfig: authConfig,
    token: token,
  );
}

class SatelliteTestContext {
  final String dbName;
  final Database db;
  final DatabaseAdapter adapter;
  final BundleMigrator migrator;
  final MockNotifier notifier;
  final MockSatelliteClient client;
  final SatelliteProcess satellite;
  final TableInfo tableInfo;
  final DateTime timestamp;
  final AuthConfig authConfig;
  final String token;

  late final AuthState authState = AuthState(clientId: authConfig.clientId!);

  SatelliteTestContext({
    required this.dbName,
    required this.db,
    required this.adapter,
    required this.migrator,
    required this.notifier,
    required this.client,
    required this.satellite,
    required this.tableInfo,
    required this.timestamp,
    required this.authConfig,
    required this.token,
  });

  Future<void> runMigrations() async {
    await migrator.up();
  }

  Future<void> clean() async {
    await _clean(dbName);
  }

  Future<void> cleanAndStopSatellite() async {
    await cleanAndStopSatelliteRaw(dbName: dbName, satellite: satellite);
  }
}

Future<ElectricClient> mockElectricClient(
  DatabaseConnectionUser db,
  Registry registry, {
  required DbName dbName,
  SatelliteOpts? options,
}) async {
  options ??= opts;

  final adapter = DriftAdapter(db);
  final migrator =
      BundleMigrator(adapter: adapter, migrations: kTestMigrations);
  final notifier = MockNotifier(dbName, eventEmitter: EventEmitter());
  final client = MockSatelliteClient();
  final satellite = SatelliteProcess(
    dbName: dbName,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    client: client,
    opts: options,
  );

  await satellite.start(const AuthConfig(clientId: ''));
  registry.satellites[dbName] = satellite;

  // Mock Electric client that does not contain the DAL
  final electric = ElectricClientImpl.internal(
    dbName: dbName,
    adapter: adapter,
    notifier: notifier,
    registry: registry,
    satellite: satellite,
    shapeManager: ShapeManagerMock(),
    dbDescription: DBSchemaRaw(fields: {}, migrations: []),
  );

  await electric.connect(insecureAuthToken({'sub': 'test-token'}));
  return electric;
}

Future<void> cleanAndStopSatelliteRaw({
  required DbName dbName,
  required SatelliteProcess satellite,
}) async {
  await satellite.stop();
  await _clean(dbName);
}

Future<void> _clean(DbName dbName) async {
  await removeFile(dbName);
  await removeFile('$dbName-journal');
}

void migrateDb(Database db, Table table) {
  final tableName = table.tableName;
  // Create the table in the database
  final createTableSQL =
      'CREATE TABLE $tableName (id REAL PRIMARY KEY, name TEXT, age INTEGER, bmi REAL, int8 INTEGER)';
  db.execute(createTableSQL);

  // Apply the initial migration on the database
  final migration = kBaseMigrations[0].statements;
  for (final stmt in migration) {
    db.execute(stmt);
  }
  final triggers = generateTableTriggers(tableName, table);

  // Apply the triggers on the database
  for (final trigger in triggers) {
    db.execute(trigger.sql);
  }
}

final kPersonTable = Table(
  namespace: 'main',
  tableName: 'personTable',
  columns: ['id', 'name', 'age', 'bmi', 'int8'],
  primary: ['id'],
  foreignKeys: [],
  columnTypes: {
    'id': (sqliteType: 'REAL', pgType: 'REAL'),
    'name': (sqliteType: 'TEXT', pgType: 'TEXT'),
    'age': (sqliteType: 'INTEGER', pgType: 'INTEGER'),
    'bmi': (sqliteType: 'REAL', pgType: 'REAL'),
    'int8': (sqliteType: 'INTEGER', pgType: 'INT8'),
  },
);
