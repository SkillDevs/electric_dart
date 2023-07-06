import 'package:electric_client/src/electric/adapter.dart';
import 'package:electric_client/src/migrators/migrators.dart';
import 'package:electric_client/src/migrators/schema.dart';
import 'package:electric_client/src/util/debug/debug.dart';
import 'package:electric_client/src/util/types.dart';

const kElectricMigrationsTable = "_electric_migrations";

final VALID_VERSION_EXP = RegExp(r"^[0-9_]+$");

class BundleMigrator implements Migrator {
  final DatabaseAdapter adapter;
  late final List<StmtMigration> migrations;

  late final String tableName;

  BundleMigrator({
    required this.adapter,
    required List<Migration> migrations,
    String? tableName,
  }) {
    this.migrations = [...kBaseMigrations, ...migrations]
        .map((migration) => makeStmtMigration(migration))
        .toList();
    this.tableName = tableName ?? kElectricMigrationsTable;
  }

  @override
  Future<int> up() async {
    final existing = await queryApplied();
    final unapplied = await validateApplied(migrations, existing);

    for (int i = 0; i < unapplied.length; i++) {
      final migration = unapplied[i];
      logger.info("applying migration: ${migration.version}");
      await apply(migration);
    }

    return unapplied.length;
  }

  Future<List<MigrationRecord>> queryApplied() async {
    // If this is the first time we're running migrations, then the
    // migrations table won't exist.
    const tableExists = '''
      SELECT 1 FROM sqlite_master
        WHERE type = 'table'
          AND name = ?
    ''';
    final resTables = await adapter.query(
      Statement(
        tableExists,
        [tableName],
      ),
    );
    if (resTables.isEmpty) {
      return [];
    }

    // The migrations table exists, so let's query the name and hash of
    // the previously applied migrations.
    final existingRecords = '''
      SELECT version FROM $tableName
        ORDER BY id ASC
    ''';
    final rows = await adapter.query(Statement(existingRecords));
    return rows
        .map(
          (r) => MigrationRecord(
            version: r["version"]! as String,
          ),
        )
        .toList();
  }

  Future<List<StmtMigration>> validateApplied(
    List<StmtMigration> migrations,
    List<MigrationRecord> existing,
  ) async {
    // First we validate that the existing records are the first migrations.
    for (var i = 0; i < existing.length; i++) {
      final migrationRecord = existing[i];
      final version = migrationRecord.version;

      final migration = migrations[i];

      if (migration.version != version) {
        throw Exception(
          "Migrations cannot be altered once applied: expecting $version at index $i.",
        );
      }
    }

    // Then we can confidently slice and return the non-existing.
    final localMigrations = [...migrations];
    localMigrations.removeRange(0, existing.length);
    return localMigrations;
  }

  @override
  Future<void> apply(StmtMigration migration) async {
    final statements = migration.statements;
    final version = migration.version;

    if (!VALID_VERSION_EXP.hasMatch(version)) {
      throw Exception(
        "Invalid migration version, must match $VALID_VERSION_EXP",
      );
    }

    final applied = '''
    INSERT INTO $tableName
        ('version', 'applied_at') VALUES (?, ?)
        ''';

    await adapter.runInTransaction([
      ...statements,
      Statement(applied, [version, DateTime.now().millisecondsSinceEpoch])
    ]);
  }

  /// Applies the provided migration only if it has not yet been applied.
  /// `migration`: The migration to apply.
  /// Returns A future that resolves to a boolean
  /// that indicates if the migration was applied.
  @override
  Future<bool> applyIfNotAlready(StmtMigration migration) async {
    final versionExists = '''
      SELECT 1 FROM $tableName
        WHERE version = ?
    ''';
    final rows = await adapter.query(
      Statement(
        versionExists,
        [migration.version],
      ),
    );

    final shouldApply = rows.isEmpty;

    if (shouldApply) {
      // This is a new migration because its version number
      // is not in our migrations table.
      await apply(migration);
    }

    return shouldApply;
  }
}
