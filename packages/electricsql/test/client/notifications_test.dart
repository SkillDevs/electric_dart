// NOTICE: Since we use drift, replicating this test file as in Electric upstream would be unnecessary. Drift already support
// stream queries, and we don't explicitly trigger 'potentiallyChanged' when the write is made through Drift.

/* import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/drivers/drift/drift.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:electricsql/util.dart';
import 'package:test/test.dart';

import '../util/sqlite.dart';
import 'generated/database.dart'; */

Future<void> main() async {
  /*  final conn = openSqliteDbMemory();
  final config = ElectricConfig(
    auth: const AuthConfig(
      token: 'test-token',
    ),
    logger: LoggerConfig(level: Level.debug),
  );

  final db = TestsDatabase.memory();

  final electricClient = await electrify<TestsDatabase>(
    dbName: 'tests_db',
    db: db,
    migrations: [],
    config: config,
    opts: ElectrifyOptions(
      registry: MockRegistry(),
    ),
  );
  final notifier = electricClient.notifier;
  final adapter = electricClient.adapter;
  await electricClient.syncTables(['Items']); // sync the Items table

  Future<int> runAndCheckNotifications(Future<void> Function() f) async {
    int notifications = 0;
    final sub = notifier.subscribeToPotentialDataChanges((_notification) {
      notifications = notifications + 1;
    });

    await f();

    notifier.unsubscribeFromPotentialDataChanges(sub);
    return notifications;
  }

// Clean the DB environment
  Future<void> cleanDB() async {
    await adapter.run(Statement('DROP TABLE IF EXISTS Items'));
    await adapter.run(
      Statement(
        'CREATE TABLE IF NOT EXISTS Items (value TEXT PRIMARY KEY NOT NULL, nbr INTEGER) WITHOUT ROWID;',
      ),
    );
  }

// Clean the DB before each test
  setUp(() async {
    await cleanDB();
  });

// Clean the DB after all tests
  tearDownAll(() async {
    await adapter.run(Statement('DROP TABLE IF EXISTS Items'));
  });

  test('create runs potentiallyChanged', () async {
    Future<void> insert() async {
      await db.into(db.items).insert(
            ItemsCompanion.insert(
              value: 'foo',
              nbr: const Value(5),
            ),
          );
    }

    final notifications = await runAndCheckNotifications(insert);
    expect(notifications, 1);
  });  */
}
