import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;

import '../drivers/drift_test.dart';
import '../util/pg_docker.dart';

Future<EmbeddedPostgresDb> makePgDatabase(String name, int port) async {
  final pgEmbeddedServer = EmbeddedPostgresServer(
    persistent: false,
    port: port,
    name: 'server-$name',
  );
  await pgEmbeddedServer.start();

  try {
    final endpoint = await pgEmbeddedServer.server.endpoint();
    final db = await openGenericPostgresDb(endpoint);

    return EmbeddedPostgresDb(
      server: pgEmbeddedServer,
      db: db,
    );
  } catch (e) {
    await pgEmbeddedServer.stop();
    rethrow;
  }
}

class EmbeddedPostgresDb {
  final EmbeddedPostgresServer server;
  final GenericDb db;

  EmbeddedPostgresDb({
    required this.server,
    required this.db,
  });

  Future<void> dispose() async {
    await db.close();
    await server.stop();
  }
}

Future<GenericDb> openGenericPostgresDb(pg.Endpoint endpoint) async {
  final db = await GenericDb.open(
    PgDatabase(
      endpoint: endpoint,
      settings: const pg.ConnectionSettings(sslMode: pg.SslMode.disable),
      enableMigrations: false,
      // logStatements: true,
    ),
  );
  return db;
}

/// A postgres connection scoped to a test
class ScopedPgDb {
  final GenericDb db;
  final String dbName;
  // Root postgres connection
  final EmbeddedPostgresDb _pgEmbedded;

  ScopedPgDb({
    required EmbeddedPostgresDb pgEmbedded,
    required this.db,
    required this.dbName,
  }) : _pgEmbedded = pgEmbedded;

  Future<void> dispose() async {
    await db.close();
    // print("Dropping database $dbName");
    await _pgEmbedded.db.customStatement('DROP DATABASE "$dbName";');
  }
}

Future<ScopedPgDb> initScopedPostgresDatabase(
  EmbeddedPostgresDb pgEmbedded,
  String dbName,
) async {
  // print("init test with db $dbName");
  await pgEmbedded.db.customStatement('CREATE DATABASE "$dbName";');

  final dbEndpoint = await pgEmbedded.server.server.endpoint(dbName: dbName);
  final dbConn = await openGenericPostgresDb(dbEndpoint);

  return ScopedPgDb(
    pgEmbedded: pgEmbedded,
    db: dbConn,
    dbName: dbName,
  );
}
