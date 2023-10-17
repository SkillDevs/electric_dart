import 'package:drift/drift.dart';
import 'package:electricsql/src/migrators/index.dart';

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

class DBSchemaCustom implements DBSchema {
  @override
  final List<Migration> migrations;

  DBSchemaCustom({
    required this.migrations,
  });
}
