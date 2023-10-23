import 'package:drift/drift.dart';
import 'package:electricsql/src/migrators/index.dart';
import 'package:meta/meta.dart';

abstract interface class DBSchema {
  List<Migration> get migrations;
}

class DBSchemaDrift implements DBSchema {
  @override
  final List<Migration> migrations;

  final DatabaseConnectionUser db;

  DBSchemaDrift({
    required this.db,
    required this.migrations,
  });
}

@visibleForTesting
class DBSchemaRaw implements DBSchema {
  @override
  final List<Migration> migrations;

  DBSchemaRaw({
    required this.migrations,
  });
}
