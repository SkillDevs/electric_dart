import 'package:drift/drift.dart' hide Migrator;
import 'package:drift/native.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/model/client.dart';
import 'package:electricsql/src/notifiers/mock.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:electricsql/util.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../satellite/common.dart';
import '../../util/sqlite.dart';
import '../generated/database.dart';

late Database conn;
late DbName dbName;
late TestsDatabase db;
late SatelliteProcess satellite;
late MockSatelliteClient client;
late Migrator migrator;
late DriftElectricClient<TestsDatabase> electric;

late List<String> log;

const authConfig = AuthConfig(
  token: 'test-token',
);

final relations = <String, Relation>{
  'Post': Relation(
    id: 0,
    schema: 'public',
    table: 'Post',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'INTEGER',
        isNullable: false,
        primaryKey: true,
      ),
      RelationColumn(
        name: 'title',
        type: 'TEXT',
        isNullable: true,
        primaryKey: false,
      ),
      RelationColumn(
        name: 'contents',
        type: 'TEXT',
        isNullable: true,
        primaryKey: false,
      ),
      RelationColumn(
        name: 'nbr',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: false,
      ),
      RelationColumn(
        name: 'authorId',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: false,
      ),
    ],
  ),
  'Profile': Relation(
    id: 1,
    schema: 'public',
    table: 'Profile',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'INTEGER',
        isNullable: false,
        primaryKey: true,
      ),
      RelationColumn(
        name: 'bio',
        type: 'TEXT',
        isNullable: true,
        primaryKey: false,
      ),
      RelationColumn(
        name: 'userId',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: false,
      ),
    ],
  ),
};

final post = <String, Object?>{
  'id': 1,
  'title': 'foo',
  'contents': 'bar',
  'nbr': 5,
  'authorId': 1,
};

final profile = <String, Object?>{
  'id': 8,
  'bio': 'foo',
  'userId': 1,
};

void main() {
  setUp(() async {
    await makeContext();
  });

  tearDown(() async {
    await cleanAndStopSatelliteRaw(dbName: dbName, satellite: satellite);
    await db.close();
    conn.dispose();
  });

  test('promise resolves when subscription starts loading', () async {
    await satellite.start(authConfig);

    client.setRelations(relations);
    client.setRelationData('Post', post);

    final ShapeSubscription(:synced) = await electric.syncTables(['Post']);
    // always await this promise otherwise the next test may issue a subscription
    // while this one is not yet fulfilled and that will lead to issues
    await synced;

    // Doesn't throw
  });

  test('synced promise resolves when subscription is fulfilled', () async {
    await satellite.start(authConfig);

    // We can request a subscription
    client.setRelations(relations);
    client.setRelationData('Profile', profile);

    final ShapeSubscription(synced: profileSynced) =
        await electric.syncTables(['Profile']);

    // Once the subscription has been acknowledged
    // we can request another one
    client.setRelations(relations);
    client.setRelationData('Post', post);

    final ShapeSubscription(:synced) = await electric.syncTables(['Post']);
    await synced;

    // Check that the data was indeed received
    final posts =
        (await db.posts.select().get()).map((e) => e.toJson()).toList();
    expect(posts, [post]);

    await profileSynced;
  });

  test('promise is rejected on failed subscription request', () async {
    await satellite.start(authConfig);

    try {
      await electric.syncTables(['Items']);
      fail('Should have thrown');
    } on SatelliteException catch (e) {
      expect(e.code, SatelliteErrorCode.tableNotFound);
    }
  });

  test('synced promise is rejected on invalid shape', () async {
    await satellite.start(authConfig);

    bool loadingPromResolved = false;

    try {
      final ShapeSubscription(:synced) = await electric.syncTables(['User']);
      loadingPromResolved = true;
      await synced;
      fail('Should have thrown');
    } on SatelliteException catch (e) {
      // fails if first promise got rejected
      // instead of the `synced` promise
      expect(loadingPromResolved, isTrue);
      expect(e.code, SatelliteErrorCode.shapeDeliveryError);
    }
  });
}

// ignore: unreachable_from_main
Future<int> runMigrations() async {
  return migrator.up();
}

Future<void> makeContext() async {
  conn = openSqliteDbMemory();
  db = TestsDatabase(NativeDatabase.opened(conn));

  client = MockSatelliteClient();
  final adapter = DriftAdapter(db);
  final migrations = <Migration>[];
  migrator = BundleMigrator(adapter: adapter, migrations: migrations);
  dbName = '.tmp/test-${randomValue()}.db';
  final notifier = MockNotifier(dbName);

  satellite = SatelliteProcess(
    dbName: dbName,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    client: client,
    opts: kSatelliteDefaults,
  );

  final baseElectricClient = ElectricClientImpl.create(
    adapter: adapter,
    notifier: notifier,
    satellite: satellite,
  );
  electric = DriftElectricClient(baseElectricClient, db);

  await init();
}

// Create a Post table in the DB first
Future<void> init() async {
  await db.customStatement('DROP TABLE IF EXISTS Post');
  await db.customStatement(
    "CREATE TABLE IF NOT EXISTS Post('id' int PRIMARY KEY, 'title' varchar, 'contents' varchar, 'nbr' int, 'authorId' int);",
  );

  await db.customStatement('DROP TABLE IF EXISTS Profile');
  await db.customStatement(
    "CREATE TABLE IF NOT EXISTS Profile('id' int PRIMARY KEY, 'bio' varchar, 'userId' int);",
  );

  log = [];
}
