// export { BundleMigrator } from './bundle'
// export { MockMigrator } from './mock'

class Migration {
  final List<String> satelliteBody;
  final String? encoding;
  final String name;
  final String sha256;
  final String title;

  Migration({
    required this.satelliteBody,
    required this.encoding,
    required this.name,
    required this.sha256,
    required this.title,
  });
}

class MigrationRecord {
  final String name;
  final String sha256;

  MigrationRecord({
    required this.name,
    required this.sha256,
  });
}

abstract class Migrator {
  Future<int> up();
}

class MigratorOptions {
  final String tableName;

  MigratorOptions({required this.tableName});
}
