import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/drivers/drift/drift.dart';
import 'package:electricsql/src/notifiers/event.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:electricsql/util.dart';
import 'package:test/test.dart';

import '../satellite/common.dart';
import 'drift/database.dart';

late TestsDatabase db;

Future<void> main() async {
  final config = ElectricConfig();

  db = TestsDatabase.memory();

  final electricClient = await electrify<TestsDatabase>(
    dbName: 'tests_db',
    db: db,
    migrations: const ElectricMigrations(
      sqliteMigrations: [],
      pgMigrations: [],
    ),
    config: config,
    opts: ElectrifyOptions(
      registry: MockRegistry(),
    ),
  );
  final notifier = electricClient.notifier;
  final adapter = electricClient.adapter;
  await electricClient.syncTable(db.items); // sync the Items table

  Future<int> runAndCheckNotifications(Future<void> Function() f) async {
    int notifications = 0;
    bool _hasListened = false;
    final unsubscribe =
        notifier.subscribeToPotentialDataChanges((_notification) {
      _hasListened = true;
      notifications = notifications + 1;
    });

    await f();

    // Let the notification run
    await Future<void>.delayed(Duration.zero);
    if (!_hasListened) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    unsubscribe();
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
  });

  test('createMany runs potentiallyChanged', () async {
    Future<void> insert() async {
      await db.items.insertAll([
        ItemsCompanion.insert(
          value: 'foo',
          nbr: const Value(5),
        ),
        ItemsCompanion.insert(
          value: 'bar',
          nbr: const Value(6),
        ),
      ]);
    }

    final notifications = await runAndCheckNotifications(insert);
    expect(notifications, 1);
  });

  test('findUnique does not run potentiallyChanged', () async {
    await populate();

    Future<void> find() async {
      await (db.items.select()..where((t) => t.value.equals('foo')))
          .getSingle();
    }

    final notifications = await runAndCheckNotifications(find);
    expect(notifications, 0);
  });

  test('update runs potentiallyChanged', () async {
    await populate();

    Future<void> update() async {
      final q = db.items.update()..where((tbl) => tbl.value.equals('foo'));
      await q.write(
        const ItemsCompanion(
          nbr: Value(18),
        ),
      );
    }

    final notifications = await runAndCheckNotifications(update);
    expect(notifications, 1);
  });

  test('update runs potentiallyChanged', () async {
    await populate();

    Future<void> delete() async {
      final q = db.items.delete()..where((tbl) => tbl.value.equals('foo'));
      await q.go();
    }

    final notifications = await runAndCheckNotifications(delete);
    expect(notifications, 1);
  });

  test(
      'electrification registers process and unregisters on close thereby releasing resources',
      () async {
    const dbName = 'test_db';
    final registry = MockRegistry();
    final electric = await mockElectricClient(db, registry, dbName: dbName);

    // Check that satellite is registered
    final satellite = electric.satellite;
    expect(registry.satellites[dbName], satellite);

    // Check that the listeners are registered
    final notifier = electric.notifier as EventNotifier;
    final events = [
      EventNames.authChange,
      EventNames.potentialDataChange,
      EventNames.connectivityStateChange,
    ];
    for (final event in events) {
      final numListeners =
          notifier.events.listeners.where((l) => l.type == event).length;
      expect(numListeners, greaterThan(0));
    }

    // Close the Electric client
    await electric.close();

    // Check that the listeners are unregistered
    for (final event in events) {
      final numListeners =
          notifier.events.listeners.where((l) => l.type == event).length;
      expect(numListeners, 0);
    }

    // Check that the Satellite process is unregistered
    expect(!registry.satellites.containsKey(dbName), true);
  });
}

Future<void> populate() async {
  await db.items.insertAll([
    ItemsCompanion.insert(
      value: 'foo',
      nbr: const Value(5),
    ),
    ItemsCompanion.insert(
      value: 'bar',
      nbr: const Value(6),
    ),
  ]);

  // Let the drift notification from the populate run
  await Future<void>.delayed(Duration.zero);
}
