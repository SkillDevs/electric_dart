import 'package:collection/collection.dart';
import 'package:electricsql/src/migrators/query_builder/builder.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/migrators/triggers.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart';

const kPostgresQueryBuilder = PostgresBuilder();

class PostgresBuilder extends QueryBuilder {
  const PostgresBuilder();

  @override
  // TODO: implement autoincrementPkType
  String get autoincrementPkType => throw UnimplementedError();

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
  // TODO: implement blobType
  String get blobType => throw UnimplementedError();

  @override
  Statement countTablesIn(String countName, List<String> tables) {
    // TODO: implement countTablesIn
    throw UnimplementedError();
  }

  @override
  List<String> createFkCompensationTrigger(
      String opType,
      String tableName,
      String childKey,
      String fkTableName,
      String joinedFkPKs,
      ForeignKey foreignKey,
      String? namespace,
      String? fkTableNamespace) {
    // TODO: implement createFkCompensationTrigger
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
  // TODO: implement defaultNamespace
  String get defaultNamespace => throw UnimplementedError();

  @override
  // TODO: implement deferForeignKeys
  String get deferForeignKeys => throw UnimplementedError();

  @override
  // TODO: implement dialect
  Dialect get dialect => throw UnimplementedError();

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
  Statement getLocalTableNames([List<String> notIn = const []]) {
    String tables = '''
      SELECT table_name AS name
        FROM information_schema.tables
        WHERE
          table_type = 'BASE TABLE' AND
          table_schema <> 'pg_catalog' AND
          table_schema <> 'information_schema'
    ''';
    if (notIn.isNotEmpty) {
      tables +=
          ''' AND table_name NOT IN (${notIn.mapIndexed((i, _) => '\$${i + 1}').join(', ')})''';
    }
    return Statement(
      tables,
      [...notIn],
    );
  }

  @override
  Statement getTableInfo(String tablename) {
    return Statement(
      r'''
        SELECT
          c.column_name AS name,
          UPPER(c.data_type) AS type,
          CASE
            WHEN c.is_nullable = 'YES' THEN 0
            ELSE 1
          END AS notnull,
          c.column_default AS dflt_value,
          (
              SELECT CASE
                       -- if the column is not part of the primary key
                       -- then return 0
                       WHEN NOT pg_attribute.attnum = ANY(pg_index.indkey) THEN 0
                       -- else, return the position of the column in the primary key
                       -- pg_index.indkey is indexed from 0 so we do + 1
                       ELSE array_position(pg_index.indkey, pg_attribute.attnum) + 1
                     END AS pk
              FROM pg_class, pg_attribute, pg_index
              WHERE pg_class.oid = pg_attribute.attrelid AND
                  pg_class.oid = pg_index.indrelid AND
                  pg_class.relname = $1 AND
                  pg_attribute.attname = c.column_name
            )
        FROM information_schema.columns AS c
        WHERE
          c.table_name = $1;
      ''',
      [tablename],
    );
  }

  @override
  // TODO: implement getVersion
  String get getVersion => throw UnimplementedError();

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
  // TODO: implement paramSign
  String get paramSign => throw UnimplementedError();

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
  String removeDeletedShadowRows(
      QualifiedTablename oplogTable, QualifiedTablename shadowTable) {
    // TODO: implement removeDeletedShadowRows
    throw UnimplementedError();
  }

  @override
  String setTagsForShadowRows(
      QualifiedTablename oplogTable, QualifiedTablename shadowTable) {
    // TODO: implement setTagsForShadowRows
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
    // TODO: implement tableExists
    throw UnimplementedError();
  }

  @override
  String toHex(String column) {
    // TODO: implement toHex
    throw UnimplementedError();
  }
}
