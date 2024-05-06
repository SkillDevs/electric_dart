import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnectionUser;
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/client/model/client.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/drivers/drift/drift_adapter.dart';
import 'package:electricsql/src/drivers/sqlite3/sqlite3_adapter.dart';
import 'package:electricsql/src/migrators/bundle.dart';
import 'package:electricsql/src/migrators/schema.dart';
import 'package:electricsql/src/migrators/triggers.dart';
import 'package:electricsql/src/notifiers/index.dart';
import 'package:electricsql/src/notifiers/mock.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:electricsql/util.dart';

import '../support/migrations.dart';
import '../support/pg_migrations.dart';
import '../support/postgres.dart';
import '../support/satellite_helpers.dart';
import '../util/io.dart';
import '../util/sqlite.dart';

// Speed up the intervals for testing.
SatelliteOpts opts(String namespace) => satelliteDefaults(namespace).copyWith(
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
  pgMigrations: [],
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
        primaryKey: 1,
      ),
      RelationColumn(
        name: 'parent',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: null,
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
        primaryKey: 1,
      ),
      RelationColumn(
        name: 'value',
        type: 'TEXT',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'other',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: null,
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
        primaryKey: 1,
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
        primaryKey: 1,
      ),
      RelationColumn(
        name: 'real',
        type: 'REAL',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'int8',
        type: 'INT8',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'bigint',
        type: 'BIGINT',
        isNullable: true,
        primaryKey: null,
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
        primaryKey: 1,
      ),
      RelationColumn(
        name: 'name',
        type: 'TEXT',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'age',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'bmi',
        type: 'REAL',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'int8',
        type: 'INT8',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'blob',
        type: 'BYTEA',
        isNullable: true,
        primaryKey: null,
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
        primaryKey: 1,
      ),
    ],
  ),
  'blobTable': Relation(
    id: 6,
    schema: 'public',
    table: 'blobTable',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'value',
        type: 'BYTEA',
        isNullable: false,
        primaryKey: null,
      ),
    ],
  ),
};

Future<SatelliteTestContext> makeContextInternal({
  required DbName dbName,
  required DatabaseAdapter adapter,
  required BundleMigratorBase migrator,
  required String namespace,
  SatelliteOpts? options,
  Future<void> Function()? stop,
}) async {
  final notifier = MockNotifier(dbName, eventEmitter: EventEmitter());
  final client = MockSatelliteClient();
  final effectiveOptions = options ?? opts(namespace);
  final satellite = SatelliteProcess(
    dbName: dbName,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    client: client,
    opts: effectiveOptions,
  );

  final tableInfo = initTableInfo(namespace);
  final timestamp = DateTime.now();

  const authConfig = AuthConfig(clientId: '');
  final token = insecureAuthToken({'sub': 'test-user'});

  return SatelliteTestContext(
    dbName: dbName,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    client: client,
    satellite: satellite,
    tableInfo: tableInfo,
    timestamp: timestamp,
    authConfig: authConfig,
    token: token,
    namespace: namespace,
    opts: effectiveOptions,
    stop: stop,
  );
}

Future<SatelliteTestContext> makeContext(
  String namespace, {
  SatelliteOpts? options,
}) async {
  await Directory('.tmp').create(recursive: true);
  final dbName = '.tmp/test-${randomValue()}.db';
  final db = openSqliteDb(dbName);
  final adapter = SqliteAdapter(db);
  final migrator =
      SqliteBundleMigrator(adapter: adapter, migrations: kTestSqliteMigrations);

  // Electric depends on Foregin keys being ON and tests do not electrify
  // So we call it explicitly
  await adapter.run(Statement('PRAGMA foreign_keys = ON'));

  return makeContextInternal(
    dbName: dbName,
    adapter: adapter,
    migrator: migrator,
    namespace: namespace,
    options: options,
  );
}

Future<SatelliteTestContext> makePgContext(
  EmbeddedPostgresDb pgEmbedded,
  String namespace, {
  SatelliteOpts? options,
}) async {
  final dbName = 'test-${randomValue()}.db';

  final scopedDb = await initScopedPostgresDatabase(pgEmbedded, dbName);

  final adapter = DriftAdapter(scopedDb.db);
  final migrator =
      PgBundleMigrator(adapter: adapter, migrations: kTestPostgresMigrations);

  return makeContextInternal(
    dbName: dbName,
    adapter: adapter,
    migrator: migrator,
    namespace: namespace,
    options: options,
    stop: () async => await scopedDb.dispose(),
  );
}

class SatelliteTestContext {
  final String dbName;
  final DatabaseAdapter adapter;
  final BundleMigratorBase migrator;
  final MockNotifier notifier;
  final MockSatelliteClient client;
  final SatelliteProcess satellite;
  final TableInfo tableInfo;
  final DateTime timestamp;
  final AuthConfig authConfig;
  final String token;
  final SatelliteOpts opts;
  final String namespace;

  late final AuthState authState = AuthState(clientId: authConfig.clientId!);

  Future<void> Function()? stop;

  SatelliteTestContext({
    required this.dbName,
    required this.adapter,
    required this.migrator,
    required this.notifier,
    required this.client,
    required this.satellite,
    required this.tableInfo,
    required this.timestamp,
    required this.authConfig,
    required this.token,
    required this.opts,
    required this.namespace,
    this.stop,
  });

  Future<void> runMigrations() async {
    await migrator.up();
  }

  Future<void> clean() async {
    await cleanDb(dbName);
  }

  Future<void> cleanAndStopSatellite() async {
    await cleanAndStopSatelliteRaw(dbName: dbName, satellite: satellite);
    await stop?.call();
  }
}

Future<ElectricClientRaw> mockElectricClient(
  DatabaseConnectionUser db,
  Registry registry, {
  required DbName dbName,
  String namespace = 'main',
  SatelliteOpts? options,
}) async {
  options ??= opts(namespace);

  final adapter = DriftAdapter(db);
  final migrator =
      SqliteBundleMigrator(adapter: adapter, migrations: kTestSqliteMigrations);
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
    dbDescription: DBSchemaRaw(fields: {}, migrations: [], pgMigrations: []),
    dialect: Dialect.sqlite,
  );

  await electric.connect(insecureAuthToken({'sub': 'test-token'}));
  return electric;
}

Future<void> cleanAndStopSatelliteRaw({
  required DbName dbName,
  required SatelliteProcess satellite,
}) async {
  await satellite.stop();
  await cleanDb(dbName);
}

Future<void> cleanDb(DbName dbName) async {
  await removeFile(dbName);
  await removeFile('$dbName-journal');
}

Future<void> migrateDb(
  DatabaseAdapter db,
  Table table,
  QueryBuilder builder,
) async {
  // First create the "main" schema (only when running on PG)
  final initialMigration = buildInitialMigration(builder);
  final migration = initialMigration[0].statements;
  final [createMainSchema, ...restMigration] = migration;
  await db.run(Statement(createMainSchema));

  // Create the table in the database on the given namespace
  final blobType = builder.dialect == Dialect.sqlite ? 'BLOB' : 'BYTEA';
  final createTableSQL =
      'CREATE TABLE ${table.qualifiedTableName} (id REAL PRIMARY KEY, name TEXT, age INTEGER, bmi REAL, int8 INTEGER, blob $blobType)';
  await db.run(Statement(createTableSQL));

  // Apply the initial migration on the database
  for (final stmt in restMigration) {
    await db.run(Statement(stmt));
  }

  // Generate the table triggers
  final triggers = generateTableTriggers(table, builder);

  // Apply the triggers on the database
  for (final trigger in triggers) {
    await db.run(Statement(trigger.sql));
  }
}

Table getPersonTable(String namespace) => Table(
      qualifiedTableName: QualifiedTablename(namespace, 'personTable'),
      columns: ['id', 'name', 'age', 'bmi', 'int8', 'blob'],
      primary: ['id'],
      foreignKeys: [],
      columnTypes: {
        'id': 'REAL',
        'name': 'TEXT',
        'age': 'INTEGER',
        'bmi': 'REAL',
        'int8': 'INT8',
        'blob': 'BYTEA',
      },
    );
