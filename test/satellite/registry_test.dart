import 'package:electric_client/auth/mock.dart';
import 'package:electric_client/config/config.dart';
import 'package:electric_client/electric/adapter.dart';
import 'package:electric_client/electric/mock.dart';
import 'package:electric_client/migrators/migrators.dart';
import 'package:electric_client/migrators/mock.dart';
import 'package:electric_client/notifiers/mock.dart';
import 'package:electric_client/satellite/mock.dart';
import 'package:electric_client/satellite/satellite.dart';
import 'package:electric_client/sockets/io.dart';
import 'package:electric_client/sockets/sockets.dart';
import 'package:electric_client/util/types.dart';
import 'package:test/test.dart';

const dbName = 'test.db';
const app = 'app';
const env = 'test';

final DatabaseAdapter adapter = MockDatabaseAdapter();
final Migrator migrator = MockMigrator();
final SocketFactory socketFactory = WebSocketIOFactory();
final notifier = MockNotifier(dbName);
final console = MockConsoleClient();

final ElectricConfigFilled config = ElectricConfigFilled(
  app: app,
  console: ConsoleConfig(
    host: '127.0.0.1',
    port: 4000,
    ssl: false,
  ),
  debug: true,
  env: env,
  migrations: [],
  replication: ReplicationConfig(host: '127.0.0.1', port: 5133, ssl: false),
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
      dbName: "a.db",
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      console: console,
      config: config,
    );
    final s2 = await mockRegistry.startProcess(
      dbName: "b.db",
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      console: console,
      config: config,
    );
    final s3 = await mockRegistry.startProcess(
      dbName: "c.db",
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      console: console,
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

  test('ensure starting multiple satellite processes works', () async {
    final mockRegistry = MockRegistry();
    final s1 = await mockRegistry.ensureStarted(
      dbName: "a.db",
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      console: console,
      config: config,
    );
    final s2 = await mockRegistry.ensureStarted(
      dbName: "b.db",
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      console: console,
      config: config,
    );
    final s3 = await mockRegistry.ensureStarted(
      dbName: "c.db",
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      console: console,
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
          "message",
          "Exception: Satellite not running for db: $dbName",
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
      _callEnsureStarted(mockRegistry, name: "a.db"),
      _callEnsureStarted(mockRegistry, name: "b.db"),
      _callEnsureStarted(mockRegistry, name: "c.db"),
    ]);
    await mockRegistry.stopAll();

    expect(mockRegistry.satellites, isEmpty);
  });

  test('stopAll works even when starting', () async {
    final mockRegistry = MockRegistry();
    final startPromises = [
      _callEnsureStarted(mockRegistry, name: "a.db"),
      _callEnsureStarted(mockRegistry, name: "b.db"),
      _callEnsureStarted(mockRegistry, name: "c.db"),
    ];

    await mockRegistry.stopAll();
    expect(mockRegistry.satellites, isEmpty);

    await Future.wait(startPromises);
    expect(mockRegistry.satellites, isEmpty);
  });

  test('stopAll works across running, stopping and starting', () async {
    final mockRegistry = MockRegistry();
    await _callEnsureStarted(mockRegistry, name: "a.db");
    await _callEnsureStarted(mockRegistry, name: "b.db");
    final p1 = _callEnsureStarted(mockRegistry, name: "c.db");
    final p2 = _callEnsureStarted(mockRegistry, name: "d.db");

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
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    socketFactory: socketFactory,
    console: console,
    config: config,
  );
}

Future<Satellite> _callEnsureStarted(
  MockRegistry mockRegistry, {
  DbName? name,
}) {
  return mockRegistry.ensureStarted(
    dbName: name ?? dbName,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    socketFactory: socketFactory,
    console: console,
    config: config,
  );
}
