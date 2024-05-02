import 'package:collection/collection.dart';
import 'package:electricsql/src/migrators/query_builder/builder.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/migrators/triggers.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart';

const kPostgresQueryBuilder = PostgresBuilder();

String quote(String col) => '"$col"';

class PostgresBuilder extends QueryBuilder {
  const PostgresBuilder();

  @override
  String get autoincrementPkType => 'SERIAL PRIMARY KEY';

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
  String get blobType => 'TEXT'; // TODO(dart): Revisar

  @override
  Statement countTablesIn(String countName, List<String> tables) {
    final sql = '''
      SELECT COUNT(table_name)::integer AS "$countName"
        FROM information_schema.tables
          WHERE
            table_type = 'BASE TABLE' AND
            table_name IN (${tables.mapIndexed((i, _) => "\$${i + 1}").join(', ')});
    ''';
    return Statement(
      sql,
      [...tables],
    );
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
    String? fkTableNamespace,
  ) {
    namespace ??= defaultNamespace;
    fkTableNamespace ??= defaultNamespace;

    // TODO: implement createFkCompensationTrigger
    throw UnimplementedError();
  }

  @override
  String createIndex(
      String indexName, QualifiedTablename onTable, List<String> columns) {
    final namespace = onTable.namespace;
    final tablename = onTable.tablename;
    return '''CREATE INDEX IF NOT EXISTS $indexName ON "$namespace"."$tablename" (${columns.map(quote).join(', ')})''';
  }

  @override
  List<String> createNoFkUpdateTrigger(
    String tablename,
    List<String> pk,
    String? namespace,
  ) {
    namespace ??= defaultNamespace;

    // TODO: implement createNoFkUpdateTrigger
    throw UnimplementedError();
  }

  @override
  List<String> createOplogTrigger(
    SqlOpType opType,
    String tableName,
    String newPKs,
    String newRows,
    String oldRows,
    String? namespace,
  ) {
    namespace ??= defaultNamespace;

    // TODO: implement createOplogTrigger
    throw UnimplementedError();
  }

  @override
  String get defaultNamespace => 'public';

  @override
  String get deferForeignKeys => 'SET CONSTRAINTS ALL DEFERRED;';

  @override
  Dialect get dialect => Dialect.postgres;

  /// **Disables** FKs for the duration of the transaction
  @override
  String get disableForeignKeys =>
      'SET LOCAL session_replication_role = replica;';

  @override
  String dropTriggerIfExists(
    String triggerName,
    String tablename,
    String? namespace,
  ) {
    namespace ??= defaultNamespace;

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
    return '$paramSign$i';
  }

  @override
  String get paramSign => r'$';

  @override
  String pgOnly(String query) {
    return query;
  }

  @override
  List<String> pgOnlyQuery(String query) {
    return [query];
  }

  @override
  String removeDeletedShadowRows(
      QualifiedTablename oplogTable, QualifiedTablename shadowTable) {
    final oplog = '"${oplogTable.namespace}"."${oplogTable.tablename}"';
    final shadow = '"${shadowTable.namespace}"."${shadowTable.tablename}"';
    // We do an inner join in a CTE instead of a `WHERE EXISTS (...)`
    // since this is not reliant on re-executing a query
    // for every row in the shadow table, but uses a PK join instead.
    return '''
      WITH 
        _relevant_shadows AS (
          SELECT DISTINCT ON (s.rowid)
            s.rowid AS rowid,
            op.optype AS last_optype
          FROM $oplog AS op
          INNER JOIN $shadow AS s
          ON s.namespace = op.namespace
            AND s.tablename = op.tablename
            AND s."primaryKey"::jsonb = op."primaryKey"::jsonb
          WHERE op.timestamp = \$1
          ORDER BY s.rowid, op.rowid DESC
        ),
        _to_be_deleted AS (
          SELECT rowid FROM _relevant_shadows WHERE last_optype = 'DELETE'
        )
      DELETE FROM $shadow
      WHERE rowid IN (SELECT rowid FROM _to_be_deleted);
    ''';
  }

  @override
  String setTagsForShadowRows(
    QualifiedTablename oplogTable,
    QualifiedTablename shadowTable,
  ) {
    final oplog = '"${oplogTable.namespace}"."${oplogTable.tablename}"';
    final shadow = '"${shadowTable.namespace}"."${shadowTable.tablename}"';
    return '''
      INSERT INTO $shadow (namespace, tablename, "primaryKey", tags)
        SELECT DISTINCT namespace, tablename, "primaryKey", \$1
          FROM $oplog AS op
          WHERE
            timestamp = \$2
            AND optype != 'DELETE'
          ON CONFLICT (namespace, tablename, "primaryKey")
        DO UPDATE SET tags = EXCLUDED.tags;
    ''';
  }

  @override
  String setTriggerSetting(String tableName, bool value, String? namespace) {
    namespace ??= defaultNamespace;

    // TODO: implement setTriggerSetting
    throw UnimplementedError();
  }

  @override
  String sqliteOnly(String query) {
    return '';
  }

  @override
  List<String> sqliteOnlyQuery(String query) {
    return [];
  }

  @override
  Statement tableExists(
    String tableName,
    String? namespace,
  ) {
    namespace ??= defaultNamespace;

    return Statement(
      r'SELECT 1 FROM information_schema.tables WHERE table_schema = $1 AND table_name = $2',
      [namespace, tableName],
    );
  }

  @override
  String toHex(String column) {
    // TODO: implement toHex
    throw UnimplementedError();
  }
}
