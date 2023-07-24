import 'package:electric_client/src/migrators/migrators.dart';

class MockMigrator implements Migrator {
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
