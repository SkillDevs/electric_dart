import 'package:electricsql/drivers/drivers.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/electric/mock.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/migrators/mock.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/notifiers/mock.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/sockets/io.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:test/test.dart';

const dbName = 'test.db';

final DatabaseAdapter adapter = MockDatabaseAdapter();
const DBSchema dbDescription =
    DBSchemaRaw(tableSchemas: {}, migrations: [], pgMigrations: []);
final Migrator migrator = MockMigrator(queryBuilder: kSqliteQueryBuilder);
final SocketFactory socketFactory = WebSocketIOFactory();
final notifier = MockNotifier(dbName);

final HydratedConfig config = hydrateConfig(
  ElectricConfigWithDialect.from(config: ElectricConfig()),
);

void main() {
  test('starting a satellite process works', () async {
    final mockRegistry = MockRegistry();
    final satellite = await _callStartProcess(mockRegistry);

    expect(satellite, isA<MockSatelliteProcess>());
  });

  test('starting multiple satellite processes works', () async {
    final mockRegistry = MockRegistry();
    final s1 = await mockRegistry.startProcess(
      dbName: 'a.db',
      dbDescription: dbDescription,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      config: config,
    );
    final s2 = await mockRegistry.startProcess(
      dbName: 'b.db',
      dbDescription: dbDescription,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      config: config,
    );
    final s3 = await mockRegistry.startProcess(
      dbName: 'c.db',
      dbDescription: dbDescription,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      config: config,
    );

    expect(s1, isA<MockSatelliteProcess>());
    expect(s2, isA<MockSatelliteProcess>());
    expect(s3, isA<MockSatelliteProcess>());
  });

  test('ensure satellite process started works', () async {
    final mockRegistry = MockRegistry();
    final satellite = await _callEnsureStarted(mockRegistry);

    expect(satellite, isA<MockSatelliteProcess>());
  });

  test('can stop failed process', () async {
    final mockRegistry = MockRegistry();

    // Mock the satellite process to fail.
    mockRegistry.setShouldFailToStart(true);

    await expectLater(
      () => _callEnsureStarted(mockRegistry),
      throwsA(anything),
    );

    // This should not throw. This tests that failed processes are properly cleaned up.
    await mockRegistry.stop(dbName);

    // Next run a successful process to make sure that works.
    mockRegistry.setShouldFailToStart(false);

    final satellite = await _callEnsureStarted(mockRegistry);
    expect(satellite, isA<MockSatelliteProcess>());
  });

  test('ensure starting multiple satellite processes works', () async {
    final mockRegistry = MockRegistry();
    final s1 = await mockRegistry.ensureStarted(
      dbName: 'a.db',
      dbDescription: dbDescription,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      config: config,
    );
    final s2 = await mockRegistry.ensureStarted(
      dbName: 'b.db',
      dbDescription: dbDescription,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      config: config,
    );
    final s3 = await mockRegistry.ensureStarted(
      dbName: 'c.db',
      dbDescription: dbDescription,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      config: config,
    );

    expect(s1, isA<MockSatelliteProcess>());
    expect(s2, isA<MockSatelliteProcess>());
    expect(s3, isA<MockSatelliteProcess>());
  });

  test('concurrent calls to ensureStarted with same dbName get same process',
      () async {
    final mockRegistry = MockRegistry();
    final satellites = await Future.wait([
      _callEnsureStarted(mockRegistry),
      _callEnsureStarted(mockRegistry),
      _callEnsureStarted(mockRegistry),
    ]);

    final s1 = satellites[0];
    final s2 = satellites[1];
    final s3 = satellites[2];

    expect(s1, s2);
    expect(s2, s3);
  });

  test('ensureAlreadyStarted fails if not already started', () async {
    final mockRegistry = MockRegistry();

    await expectLater(
      mockRegistry.ensureAlreadyStarted(dbName),
      throwsA(
        isA<Exception>().having(
          (Exception e) => e.toString(),
          'message',
          'Exception: Satellite not running for db: $dbName',
        ),
      ),
    );
  });

  test('ensureAlreadyStarted succeeds if fully started', () async {
    final mockRegistry = MockRegistry();
    await _callEnsureStarted(mockRegistry);
    final satellite = await mockRegistry.ensureAlreadyStarted(dbName);

    expect(satellite, isA<MockSatelliteProcess>());
  });

  test('ensureAlreadyStarted succeeds if in the process of starting', () async {
    final mockRegistry = MockRegistry();
    final promise = _callEnsureStarted(mockRegistry);
    final satellite = await mockRegistry.ensureAlreadyStarted(dbName);

    expect(satellite, isA<MockSatelliteProcess>());
    expect(satellite, await promise);
  });

  test('stop defaults to a noop', () async {
    final mockRegistry = MockRegistry();
    await mockRegistry.stop(dbName);
  });

  test('stop works if running', () async {
    final mockRegistry = MockRegistry();
    final satellite = await _callEnsureStarted(mockRegistry);
    expect(mockRegistry.satellites[dbName], satellite);

    await mockRegistry.stop(dbName);
    expect(mockRegistry.satellites[dbName], null);
  });

  test('stop works if starting', () async {
    final mockRegistry = MockRegistry();
    final promise = _callEnsureStarted(mockRegistry);
    await mockRegistry.stop(dbName);

    expect(mockRegistry.satellites[dbName], null);

    await promise;
    expect(mockRegistry.satellites[dbName], null);
  });

  test('stopAll works', () async {
    final mockRegistry = MockRegistry();
    await Future.wait([
      _callEnsureStarted(mockRegistry, name: 'a.db'),
      _callEnsureStarted(mockRegistry, name: 'b.db'),
      _callEnsureStarted(mockRegistry, name: 'c.db'),
    ]);
    await mockRegistry.stopAll();

    expect(mockRegistry.satellites, isEmpty);
  });

  test('stopAll works even when starting', () async {
    final mockRegistry = MockRegistry();
    final startPromises = [
      _callEnsureStarted(mockRegistry, name: 'a.db'),
      _callEnsureStarted(mockRegistry, name: 'b.db'),
      _callEnsureStarted(mockRegistry, name: 'c.db'),
    ];

    await mockRegistry.stopAll();
    expect(mockRegistry.satellites, isEmpty);

    await Future.wait(startPromises);
    expect(mockRegistry.satellites, isEmpty);
  });

  test('stopAll works across running, stopping and starting', () async {
    final mockRegistry = MockRegistry();
    await _callEnsureStarted(mockRegistry, name: 'a.db');
    await _callEnsureStarted(mockRegistry, name: 'b.db');
    final p1 = _callEnsureStarted(mockRegistry, name: 'c.db');
    final p2 = _callEnsureStarted(mockRegistry, name: 'd.db');

    final p3 = mockRegistry.stop('a.db');
    final p4 = mockRegistry.stop('c.db');

    await mockRegistry.stopAll();
    expect(mockRegistry.satellites, isEmpty);

    await Future.wait([p1, p2, p3, p4]);
    expect(mockRegistry.satellites, isEmpty);
  });
}

Future<Satellite> _callStartProcess(MockRegistry mockRegistry) {
  return mockRegistry.startProcess(
    dbName: dbName,
    dbDescription: dbDescription,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    socketFactory: socketFactory,
    config: config,
  );
}

Future<Satellite> _callEnsureStarted(
  MockRegistry mockRegistry, {
  DbName? name,
}) {
  return mockRegistry.ensureStarted(
    dbName: name ?? dbName,
    dbDescription: dbDescription,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    socketFactory: socketFactory,
    config: config,
  );
}
