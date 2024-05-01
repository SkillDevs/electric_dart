import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/migrators/query_builder/builder.dart';

class MockMigrator implements Migrator {
  @override
  QueryBuilder get queryBuilder => throw UnimplementedError();

  @override
  Future<int> up() async {
    return 0;
  }

  @override
  Future<void> apply(StmtMigration migration) async {
    return;
  }

  @override
  Future<bool> applyIfNotAlready(StmtMigration migration) async {
    return true;
  }

  @override
  Future<String?> querySchemaVersion() async {
    return null;
  }
}
