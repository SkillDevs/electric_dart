import 'package:electricsql/src/migrators/query_builder/builder.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart';

const kSqliteQueryBuilder = SqliteBuilder();

class SqliteBuilder implements QueryBuilder {
  const SqliteBuilder();

  @override
  Dialect get dialect => Dialect.sqlite;

  @override
  String get autoincrementPkType => 'INTEGER PRIMARY KEY AUTOINCREMENT';

  @override
  String get blobType => 'BLOB';

  @override
  String get defaultNamespace => 'main';

  @override
  String get deferForeignKeys => 'PRAGMA defer_foreign_keys = ON;';

  @override
  String get paramSign => '?';

  @override
  List<Statement> batchedInsertOrReplace(
      String table,
      List<String> columns,
      List<Map<String, Object?>> records,
      List<String> conflictCols,
      List<String> updateCols,
      int maxSqlParameters,
      String? schema) {
    // TODO: implement batchedInsertOrReplace
    throw UnimplementedError();
  }

  @override
  Statement countTablesIn(String countName, List<String> tables) {
    // TODO: implement countTablesIn
    throw UnimplementedError();
  }

  @override
  String createIndex(
      String indexName, QualifiedTablename onTable, List<String> columns) {
    // TODO: implement createIndex
    throw UnimplementedError();
  }

  @override
  List<String> createNoFkUpdateTrigger(
      String tablename, List<String> pk, String? namespace) {
    // TODO: implement createNoFkUpdateTrigger
    throw UnimplementedError();
  }

  @override
  List<String> createOplogTrigger(SqlOpType opType, String tableName,
      String newPKs, String newRows, String oldRows, String? namespace) {
    // TODO: implement createOplogTrigger
    throw UnimplementedError();
  }

  @override
  List<String> createOrReplaceDeleteTrigger(
      String tableName, String newPKs, String newRows, String oldRows,
      [String? namespace]) {
    // TODO: implement createOrReplaceDeleteTrigger
    throw UnimplementedError();
  }

  @override
  List<String> createOrReplaceInsertTrigger(
      String tableName, String newPKs, String newRows, String oldRows,
      [String? namespace]) {
    // TODO: implement createOrReplaceInsertTrigger
    throw UnimplementedError();
  }

  @override
  List<String> createOrReplaceNoFkUpdateTrigger(
      String tablename, List<String> pk, String? namespace) {
    // TODO: implement createOrReplaceNoFkUpdateTrigger
    throw UnimplementedError();
  }

  @override
  List<String> createOrReplaceOplogTrigger(SqlOpType opType, String tableName,
      String newPKs, String newRows, String oldRows,
      [String? namespace]) {
    // TODO: implement createOrReplaceOplogTrigger
    throw UnimplementedError();
  }

  @override
  List<String> createOrReplaceUpdateTrigger(
      String tableName, String newPKs, String newRows, String oldRows,
      [String? namespace]) {
    // TODO: implement createOrReplaceUpdateTrigger
    throw UnimplementedError();
  }

  @override
  // TODO: implement disableForeignKeys
  String get disableForeignKeys => throw UnimplementedError();

  @override
  String dropTriggerIfExists(
      String triggerName, String tablename, String? namespace) {
    // TODO: implement dropTriggerIfExists
    throw UnimplementedError();
  }

  @override
  Statement getLocalTableNames(List<String>? notIn) {
    // TODO: implement getLocalTableNames
    throw UnimplementedError();
  }

  @override
  Statement getTableInfo(String tablename) {
    // TODO: implement getTableInfo
    throw UnimplementedError();
  }

  @override
  String get getVersion => 'SELECT sqlite_version() AS version';

  @override
  String hexValue(String hexString) {
    // TODO: implement hexValue
    throw UnimplementedError();
  }

  @override
  Statement insertOrIgnore(String table, List<String> columns,
      List<Object?> values, String? schema) {
    // TODO: implement insertOrIgnore
    throw UnimplementedError();
  }

  @override
  Statement insertOrReplace(
      String table,
      List<String> columns,
      List<Object?> values,
      List<String> conflictCols,
      List<String> updateCols,
      String? schema) {
    // TODO: implement insertOrReplace
    throw UnimplementedError();
  }

  @override
  Statement insertOrReplaceWith(
      String table,
      List<String> columns,
      List<Object?> values,
      List<String> conflictCols,
      List<String> updateCols,
      List<Object?> updateVals,
      String? schema) {
    // TODO: implement insertOrReplaceWith
    throw UnimplementedError();
  }

  @override
  String makePositionalParam(int i) {
    // TODO: implement makePositionalParam
    throw UnimplementedError();
  }

  @override
  String pgOnly(String query) {
    // TODO: implement pgOnly
    throw UnimplementedError();
  }

  @override
  List<String> pgOnlyQuery(String query) {
    // TODO: implement pgOnlyQuery
    throw UnimplementedError();
  }

  @override
  String setTriggerSetting(String tableName, bool value, String? namespace) {
    // TODO: implement setTriggerSetting
    throw UnimplementedError();
  }

  @override
  String sqliteOnly(String query) {
    // TODO: implement sqliteOnly
    throw UnimplementedError();
  }

  @override
  List<String> sqliteOnlyQuery(String query) {
    // TODO: implement sqliteOnlyQuery
    throw UnimplementedError();
  }

  @override
  Statement tableExists(String tableName, String? namespace) {
    return Statement(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      [tableName],
    );
  }

  @override
  String toHex(String column) {
    // TODO: implement toHex
    throw UnimplementedError();
  }
}
