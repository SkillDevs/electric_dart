import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:drift_postgres/drift_postgres.dart';

/// Whether to use Electric backed by a Postgres database as a client.
/// It would sync with the "master" Postgres database or other "SQLite" clients.
const _kUsePostgresDriver = false;

Future<String> getDatabasePath() async {
  final appDocsDir = await getApplicationDocumentsDirectory();
  final appDir = Directory(join(appDocsDir.path, "todos-electric"));
  if (!await appDir.exists()) {
    await appDir.create(recursive: true);
  }

  final todosDbPath = join(appDir.path, "todos.db");

  return todosDbPath;
}

/// Obtains a database connection for running drift in a Dart VM.
DatabaseConnection connect() {
  if (_kUsePostgresDriver) {
    return _getPostgresDbConnection();
  }

  return DatabaseConnection.delayed(Future(() async {
    final dbPath = await getDatabasePath();
    print("Using todos database at path $dbPath");

    return NativeDatabase.createBackgroundConnection(File(dbPath));
  }));
}

DatabaseConnection _getPostgresDbConnection() {
  return DatabaseConnection(
    PgDatabase(
      enableMigrations: false,
      endpoint: pg.Endpoint(
        // FILL THE ENDPOINT WITH APPROPRIATE VALUES
        host: 'localhost',
        database: 'postgres',
        username: 'postgres',
        password: 'postgres',
        port: 5444, // Using a port different than the master Postgres
      ),
      settings: const pg.ConnectionSettings(sslMode: pg.SslMode.disable),
    ),
  );
}

Future<void> deleteTodosDbFile() async {
  final dbFile = File(await getDatabasePath());
  if (dbFile.existsSync()) {
    await dbFile.delete();
  }
}
