import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/util/types.dart';

class Migration {
  final List<String> statements;
  final String version;

  const Migration({
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
  const Migrator();

  abstract final QueryBuilder queryBuilder;

  Future<int> up();
  Future<void> apply(StmtMigration migration);
  Future<bool> applyIfNotAlready(StmtMigration migration);
  Future<String?> querySchemaVersion();
}
