// import 'dart:convert';

import 'package:drift/drift.dart' hide Migrator;
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/model/client.dart';
import 'package:electricsql/src/client/model/schema.dart' hide Relation;
import 'package:electricsql/src/drivers/drift/sync_input.dart';
import 'package:electricsql/src/notifiers/mock.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:electricsql/util.dart';
import 'package:test/test.dart';

import '../../satellite/common.dart';
import '../../support/log_mock.dart';
import '../drift/database.dart';

late DbName dbName;
late TestsDatabase db;
late SatelliteProcess satellite;
late MockSatelliteClient client;
late Migrator migrator;
late DriftElectricClient<TestsDatabase> electric;

List<String> log = [];

final authToken = insecureAuthToken({'sub': 'test-token'});

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
        primaryKey: 1,
      ),
      RelationColumn(
        name: 'title',
        type: 'TEXT',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'contents',
        type: 'TEXT',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'nbr',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'authorId',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: null,
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
        primaryKey: 1,
      ),
      RelationColumn(
        name: 'bio',
        type: 'TEXT',
        isNullable: true,
        primaryKey: null,
      ),
      RelationColumn(
        name: 'userId',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: null,
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

Future<void> startSatellite(SatelliteProcess satellite, String token) async {
  await satellite.start(null);
  satellite.setToken(token);
  await satellite.connectWithBackoff();
}

void main() {
  setupLoggerMock(() => log);

  setUp(() async {
    await makeContext();
  });

  tearDown(() async {
    await cleanAndStopSatelliteRaw(
      dbName: dbName,
      satellite: satellite,
      stopDb: () => db.close(),
    );
  });

  test('promise resolves when subscription starts loading', () async {
    await startSatellite(satellite, authToken);

    client.setRelations(relations);
    client.setRelationData('Post', post);

    final ShapeSubscription(:synced) = await electric.syncTable(db.post);
    // always await this promise otherwise the next test may issue a subscription
    // while this one is not yet fulfilled and that will lead to issues
    await synced;

    // Doesn't throw
  });

  test('synced promise resolves when subscription is fulfilled', () async {
    await startSatellite(satellite, authToken);

    // We can request a subscription
    client.setRelations(relations);
    client.setRelationData('Profile', profile);

    final ShapeSubscription(synced: profileSynced) =
        await electric.syncTable(db.profile);

    // Once the subscription has been acknowledged
    // we can request another one
    client.setRelations(relations);
    client.setRelationData('Post', post);

    final ShapeSubscription(:synced) = await electric.syncTable(db.post);
    await synced;

    // Check that the data was indeed received
    final posts =
        (await db.post.select().get()).map((e) => e.toJson()).toList();
    expect(posts, [post]);

    await profileSynced;
  });

  test('promise is rejected on failed subscription request', () async {
    await startSatellite(satellite, authToken);

    try {
      await electric.syncTable(db.items);
      fail('Should have thrown');
    } on SatelliteException catch (e) {
      expect(e.code, SatelliteErrorCode.tableNotFound);
    }
  });

  test('synced promise is rejected on invalid shape', () async {
    await startSatellite(satellite, authToken);

    bool loadingPromResolved = false;

    try {
      final ShapeSubscription(:synced) = await electric.syncTable(db.user);
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

  test('nested shape is constructed', () async {
    await startSatellite(satellite, authToken);

    client.setRelations(relations);

    final input = SyncInputRaw(
      tableName: 'Post',
      where: SyncWhere({
        'OR': [
          {'id': 5},
          {'id': 42},
        ],
        'NOT': [
          {'id': 1},
          {'id': 2},
        ],
        'AND': [
          {'nbr': 6},
          {'nbr': 7},
        ],
        'title': 'foo',
        'contents': "important'",
      }),
      include: [
        IncludeRelRaw(
          foreignKey: ['authorId'],
          select: SyncInputRaw(
            tableName: 'User',
            include: [
              IncludeRelRaw(
                foreignKey: ['userId'],
                select: SyncInputRaw(
                  tableName: 'Profile',
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final shape = computeShape(input);

    expect(
      shape,
      Shape(
        tablename: 'Post',
        where:
            "this.title = 'foo' AND this.contents = 'important''' AND this.nbr = 6 AND this.nbr = 7 AND ((this.id = 5) OR (this.id = 42)) AND NOT ((this.id = 1) OR (this.id = 2))",
        include: [
          Rel(
            foreignKey: ['authorId'],
            select: Shape(
              tablename: 'User',
              include: [
                Rel(
                  foreignKey: ['userId'],
                  select: Shape(
                    tablename: 'Profile',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });

  test('shape from drift', () async {
    final shape = computeShapeForDrift(
      db,
      db.post,
      where: (p) =>
          p.title.equals('foo') &
          p.contents.equals("important'") &
          p.nbr.equals(6) &
          p.nbr.equals(7) &
          (p.id.isIn([3, 2]) | p.title.like('%hello')) &
          (p.id.equals(1) | p.id.equals(2)).not(),
      include: (p) => [
        SyncInputRelation.from(
          p.$relations.author,
          // This is not allowed on the server (no filtering of many-to-one relations), but we're just testing that `where`
          // clauses on nested objects are parsed correctly
          where: (u) => u.id.isSmallerThanValue(5),
          include: (u) => [
            SyncInputRelation.from(u.$relations.profile),
          ],
        ),
      ],
    );
    // print(JsonEncoder.withIndent('  ').convert(shape.toMap()));

    expect(
      shape,
      Shape(
        tablename: 'Post',
        where:
            '"this"."title" = \'foo\' AND "this"."contents" = \'important\'\'\' AND "this"."nbr" = 6 AND "this"."nbr" = 7 AND ("this"."id" IN (3, 2) OR "this"."title" LIKE \'%hello\') AND NOT ("this"."id" = 1 OR "this"."id" = 2)',
        include: [
          Rel(
            foreignKey: ['authorId'],
            select: Shape(
              tablename: 'User',
              where: '"this"."id" < 5',
              include: [
                Rel(
                  foreignKey: ['userId'],
                  select: Shape(
                    tablename: 'Profile',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

// ignore: unreachable_from_main
Future<int> runMigrations() async {
  return migrator.up();
}

Future<void> makeContext() async {
  db = TestsDatabase.memory();

  client = MockSatelliteClient();
  final adapter = DriftAdapter(db);
  final migrations = <Migration>[];
  final pgMigrations = <Migration>[];

  migrator = SqliteBundleMigrator(adapter: adapter, migrations: migrations);
  dbName = '.tmp/test-${randomValue()}.db';
  final notifier = MockNotifier(dbName);
  final registry = MockRegistry();

  satellite = SatelliteProcess(
    dbName: dbName,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    client: client,
    opts: satelliteDefaults(migrator.queryBuilder.defaultNamespace),
  );

  final dbSchema = DBSchemaDrift(
    db: db,
    migrations: migrations,
    pgMigrations: pgMigrations,
  );

  final baseElectricClient = ElectricClientImpl.create(
    dbName: dbName,
    adapter: adapter,
    notifier: notifier,
    satellite: satellite,
    dbDescription: dbSchema,
    registry: registry,
    dialect: Dialect.sqlite,
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
