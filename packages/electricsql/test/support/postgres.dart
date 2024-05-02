import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;

import '../drivers/drift_test.dart';
import '../util/pg_docker.dart';

Future<EmbeddedPostgresDb> makePgDatabase(String name, int port) async {
  final pgEmbeddedServer = EmbeddedPostgresServer(
    persistent: false,
    port: port,
    name: 'server-$name',
    databaseName: name,
  );
  await pgEmbeddedServer.start();

  try {
    final endpoint = await pgEmbeddedServer.server.endpoint();
    final db = await GenericDb.open(
      PgDatabase(
        endpoint: endpoint,
        settings: const pg.ConnectionSettings(sslMode: pg.SslMode.disable),
        enableMigrations: false,
      ),
    );

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
  final DatabaseConnectionUser db;

  EmbeddedPostgresDb({
    required this.server,
    required this.db,
  });

  Future<void> dispose() async {
    await db.close();
    await server.stop();
  }
}
