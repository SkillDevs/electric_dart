// export { BundleMigrator } from './bundle'
// export { MockMigrator } from './mock'

import 'package:electricsql/src/util/types.dart';

class Migration {
  final List<String> statements;
  final String version;

  Migration({
    required this.statements,
    required this.version,
  });
}

class StmtMigration {
  final List<Statement> statements;
  final String version;

  StmtMigration({
    required this.statements,
    required this.version,
  });
}

class MigrationRecord {
  final String version;

  MigrationRecord({
    required this.version,
  });
}

StmtMigration makeStmtMigration(Migration migration) {
  return StmtMigration(
    statements: migration.statements.map((sql) => Statement(sql)).toList(),
    version: migration.version,
  );
}

abstract class Migrator {
  Future<int> up();
  Future<void> apply(StmtMigration migration);
  Future<bool> applyIfNotAlready(StmtMigration migration);
  Future<String?> querySchemaVersion();
}

class MigratorOptions {
  final String tableName;

  MigratorOptions({required this.tableName});
}
