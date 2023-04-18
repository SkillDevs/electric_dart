import 'package:electric_client/electric/adapter.dart';
import 'package:electric_client/migrators/migrators.dart';
import 'package:electric_client/migrators/schema.dart';
import 'package:electric_client/util/debug/debug.dart';
import 'package:electric_client/util/types.dart';

const kElectricMigrationsTable = "_electric_migrations";

final VALID_NAME_EXP = RegExp(r"^[a-z0-9_]+$", caseSensitive: false);
final VALID_SHA256_EXP = RegExp(r"^[a-z0-9]{64}$");

class BundleMigrator implements Migrator {
  final DatabaseAdapter adapter;
  late final List<Migration> migrations;

  late final String tableName;

  BundleMigrator({
    required this.adapter,
    required List<Migration> migrations,
    String? tableName,
  }) {
    this.migrations = [...kBaseMigrations, ...migrations];
    this.tableName = tableName ?? kElectricMigrationsTable;
  }

  @override
  Future<int> up() async {
    final existing = await queryApplied();
    final unapplied = await validateApplied(migrations, existing);

    for (int i = 0; i < unapplied.length; i++) {
      final migration = unapplied[i];
      logger.info("applying migration: ${migration.name} ${migration.sha256}");
      await apply(migration);
    }

    return unapplied.length;
  }

  Future<List<MigrationRecord>> queryApplied() async {
    // If this is the first time we're running migrations, then the
    // migrations table won't exist.
    const tableExists = '''
      SELECT count(name) as numTables FROM sqlite_master
        WHERE type = 'table'
          AND name = ?
    ''';
    final res = await adapter.query(Statement(
      tableExists,
      [tableName],
    ));
    final numTables = res.first["numTables"]! as int;
    if (numTables == 0) {
      return [];
    }

    // The migrations table exists, so let's query the name and hash of
    // the previously applied migrations.
    final existingRecords = '''
      SELECT name, sha256 FROM $tableName
        ORDER BY id ASC
    ''';
    final rows = await adapter.query(Statement(existingRecords));
    return rows
        .map((r) => MigrationRecord(
              name: r["name"]! as String,
              sha256: r["sha256"]! as String,
            ))
        .toList();
  }

  Future<List<Migration>> validateApplied(List<Migration> migrations, List<MigrationRecord> existing) async {
    // First we validate that the existing records are the first migrations.
    for (var i = 0; i < existing.length; i++) {
      final migrationRecord = existing[i];
      final name = migrationRecord.name;
      final sha256 = migrationRecord.sha256;

      final migration = migrations[i];

      if (migration.name != name) {
        throw Exception("Migrations cannot be altered once applied: expecting $name at index $i.");
      }

      if (migration.sha256 != sha256) {
        throw Exception("Migrations cannot be altered once applied: expecting $name to have sha256 of $sha256");
      }
    }

    // Then we can confidently slice and return the non-existing.
    final localMigrations = [...migrations];
    localMigrations.removeRange(0, existing.length);
    return localMigrations;
  }

  Future<void> apply(Migration migration) async {
    final name = migration.name;
    final sha256 = migration.sha256;
    final satelliteBody = migration.satelliteBody;

    if (!VALID_NAME_EXP.hasMatch(name)) {
      throw Exception("Invalid migration name, must match $VALID_NAME_EXP");
    }

    if (!VALID_SHA256_EXP.hasMatch(sha256)) {
      throw Exception("Invalid migration sha256, must match $VALID_SHA256_EXP");
    }

    final applied = '''
    INSERT INTO $tableName
        ('name', 'sha256', 'applied_at') VALUES (?, ?, ?)
        ''';

    await adapter.runInTransaction([
      ...satelliteBody.map((sql) => Statement(sql)),
      Statement(applied, [name, sha256, DateTime.now().millisecondsSinceEpoch])
    ]);
  }
}
