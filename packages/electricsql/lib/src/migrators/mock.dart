import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';

class MockMigrator implements Migrator {
  final QueryBuilder? _queryBuilder;

  MockMigrator({QueryBuilder? queryBuilder}) : _queryBuilder = queryBuilder;

  @override
  QueryBuilder get queryBuilder {
    if (_queryBuilder == null) {
      throw UnimplementedError();
    }
    return _queryBuilder!;
  }

  @override
  Future<int> up() async {
    return 0;
  }

  @override
  Future<void> apply(
    StmtMigration migration, {
    ForeignKeyChecks fkChecks = ForeignKeyChecks.inherit,
  }) async {
    return;
  }

  @override
  Future<bool> applyIfNotAlready(
    StmtMigration migration, {
    ForeignKeyChecks fkChecks = ForeignKeyChecks.inherit,
  }) async {
    return true;
  }

  @override
  Future<String?> querySchemaVersion() async {
    return null;
  }
}
