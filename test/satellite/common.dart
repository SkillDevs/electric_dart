// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:electric_client/electric_dart.dart';
import 'package:electric_client/src/auth/auth.dart';
import 'package:electric_client/src/auth/mock.dart';
import 'package:electric_client/src/notifiers/mock.dart';
import 'package:electric_client/src/proto/satellite.pb.dart';
import 'package:electric_client/src/satellite/config.dart';
import 'package:electric_client/src/satellite/mock.dart';
import 'package:electric_client/src/satellite/process.dart';
import 'package:electric_client/src/util/random.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart';

import '../support/migrations.dart';
import '../support/satellite_helpers.dart';
import '../util/io.dart';

Map<String, Relation> kTestRelations = {
  "child": Relation(
    id: 0,
    schema: 'public',
    table: 'child',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'INTEGER',
        primaryKey: true,
      ),
      RelationColumn(
        name: 'parent',
        type: 'INTEGER',
        primaryKey: false,
      ),
    ],
  ),
  "parent": Relation(
    id: 1,
    schema: 'public',
    table: 'parent',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'INTEGER',
        primaryKey: true,
      ),
      RelationColumn(
        name: 'value',
        type: 'TEXT',
        primaryKey: false,
      ),
      RelationColumn(
        name: 'other',
        type: 'INTEGER',
        primaryKey: false,
      ),
    ],
  ),
};

// Speed up the intervals for testing.
final opts = kSatelliteDefaults.copyWith(
  minSnapshotWindow: const Duration(milliseconds: 40),
  pollingInterval: const Duration(milliseconds: 200),
);

Future<SatelliteTestContext> makeContext({
  SatelliteOpts? options,
}) async {
  await Directory(".tmp").create(recursive: true);

  final dbName = '.tmp/test-${randomValue()}.db';
  final db = sqlite3.open(dbName);
  final adapter = SqliteAdapter(db);
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

  final authConfig = AuthConfig(clientId: '', token: 'test-token');

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

  late final AuthState authState =
      AuthState(clientId: authConfig.clientId!, token: authConfig.token);

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
  });

  Future<void> runMigrations() async {
    await migrator.up();
  }

  Future<void> clean() async {
    await removeFile(dbName);
    await removeFile("$dbName-journal");
  }

  Future<void> cleanAndStopSatellite() async {
    await clean();
    await satellite.stop();
  }
}
