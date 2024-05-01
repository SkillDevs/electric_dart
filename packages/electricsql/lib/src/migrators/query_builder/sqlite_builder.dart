import 'package:electricsql/src/migrators/query_builder/builder.dart';
import 'package:electricsql/src/migrators/triggers.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart';

const kSqliteQueryBuilder = SqliteBuilder();

class SqliteBuilder extends QueryBuilder {
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

  List<String> get metaTables => [
        'sqlite_schema',
        'sqlite_sequence',
        'sqlite_temp_schema',
      ];

  @override
  List<Statement> batchedInsertOrReplace(
    String table,
    List<String> columns,
    List<Map<String, Object?>> records,
    List<String> conflictCols,
    List<String> updateCols,
    int maxSqlParameters,
    String? schema,
  ) {
    schema ??= defaultNamespace;

    final baseSql =
        'INSERT OR REPLACE INTO $schema.$table (${columns.join(', ')}) VALUES ';
    return prepareInsertBatchedStatements(
      baseSql,
      columns,
      records,
      maxSqlParameters,
    );
  }

  @override
  Statement countTablesIn(String countName, List<String> tables) {
    final sql = '''
      SELECT count(name) as $countName FROM sqlite_master
        WHERE type='table'
        AND name IN (${tables.map((_) => '?').join(', ')})
    ''';
    return Statement(
      sql,
      tables,
    );
  }

  @override
  String createIndex(
    String indexName,
    QualifiedTablename onTable,
    List<String> columns,
  ) {
    final namespace = onTable.namespace;
    final tablename = onTable.tablename;
    return 'CREATE INDEX IF NOT EXISTS $namespace.$indexName ON $tablename (${columns.join(', ')})';
  }

  @override
  List<String> createNoFkUpdateTrigger(
    String tablename,
    List<String> pk,
    String? namespace,
  ) {
    namespace ??= defaultNamespace;

    return [
      '''
    CREATE TRIGGER update_ensure_${namespace}_${tablename}_primarykey
      BEFORE UPDATE ON "$namespace"."$tablename"
    BEGIN
      SELECT
        CASE
          ${pk.map((col) => '''WHEN old."$col" != new."$col" THEN\n\t\tRAISE (ABORT, 'cannot change the value of column $col as it belongs to the primary key')''').join('\n')}
        END;
    END;
      ''',
    ];
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

    final opTypeLower = opType.name.toLowerCase();
    final pk = createPKJsonObject(newPKs);
    // Update has both the old and the new row
    // Delete only has the old row
    final newRecord =
        opType == SqlOpType.delete ? 'NULL' : createJsonObject(newRows);
    // Insert only has the new row
    final oldRecord =
        opType == SqlOpType.insert ? 'NULL' : createJsonObject(oldRows);

    return [
      '''
CREATE TRIGGER ${opTypeLower}_${namespace}_${tableName}_into_oplog
  AFTER ${opType.text} ON "$namespace"."$tableName"
  WHEN 1 = (SELECT flag from _electric_trigger_settings WHERE namespace = '$namespace' AND tablename = '$tableName')
BEGIN
  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
  VALUES ('$namespace', '$tableName', '${opType.text}', $pk, $newRecord, $oldRecord, NULL);
END;''',
    ];
  }

  @override
  String get disableForeignKeys => 'PRAGMA foreign_keys = OFF;';

  @override
  String dropTriggerIfExists(
    String triggerName,
    String tablename,
    String? namespace,
  ) {
    return 'DROP TRIGGER IF EXISTS $triggerName;';
  }

  @override
  Statement getLocalTableNames(List<String>? notIn) {
    final ignore = [...metaTables];
    if (notIn != null) {
      ignore.addAll(notIn);
    }
    final tables = '''
      SELECT name FROM sqlite_master
        WHERE type = 'table' AND
              name NOT IN (${ignore.map((_) => '?').join(',')})
    ''';
    return Statement(
      tables,
      ignore,
    );
  }

  @override
  Statement getTableInfo(String tablename) {
    return Statement(
      'SELECT name, type, "notnull", dflt_value, pk FROM pragma_table_info(?)',
      [tablename],
    );
  }

  @override
  String get getVersion => 'SELECT sqlite_version() AS version';

  @override
  String hexValue(String hexString) {
    return "x'$hexString'";
  }

  @override
  Statement insertOrIgnore(
    String table,
    List<String> columns,
    List<Object?> values,
    String? schema,
  ) {
    schema ??= defaultNamespace;

    return Statement(
      '''
        INSERT OR IGNORE INTO $schema.$table (${columns.join(', ')})
          VALUES (${columns.map((_) => '?').join(', ')});
      ''',
      values,
    );
  }

  @override
  Statement insertOrReplace(
    String table,
    List<String> columns,
    List<Object?> values,
    List<String> conflictCols,
    List<String> updateCols,
    String? schema,
  ) {
    schema ??= defaultNamespace;

    return Statement(
      '''
        INSERT OR REPLACE INTO $schema.$table (${columns.join(', ')})
        VALUES (${columns.map((_) => '?').join(', ')})
      ''',
      values,
    );
  }

  @override
  Statement insertOrReplaceWith(
    String table,
    List<String> columns,
    List<Object?> values,
    List<String> conflictCols,
    List<String> updateCols,
    List<Object?> updateVals,
    String? schema,
  ) {
    schema ??= defaultNamespace;

    final insertOrReplaceRes = insertOrReplace(
      table,
      columns,
      values,
      conflictCols,
      updateCols,
      schema,
    );
    return Statement(
      '${insertOrReplaceRes.sql} ON CONFLICT DO UPDATE SET ${updateCols.map((col) => '$col = ?').join(', ')}',
      [...insertOrReplaceRes.args!, updateVals],
    );
  }

  @override
  String makePositionalParam(int i) {
    return paramSign;
  }

  @override
  String pgOnly(String query) {
    return '';
  }

  @override
  List<String> pgOnlyQuery(String query) {
    return [];
  }

  @override
  String setTriggerSetting(
    String tableName,
    bool value,
    String? namespace,
  ) {
    namespace ??= defaultNamespace;

    return "INSERT OR IGNORE INTO _electric_trigger_settings (namespace, tablename, flag) VALUES ('$namespace', '$tableName', ${value ? 1 : 0});";
  }

  @override
  String sqliteOnly(String query) {
    return query;
  }

  @override
  List<String> sqliteOnlyQuery(String query) {
    return [query];
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
    return 'hex($column)';
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

    final opTypeLower = opType.toLowerCase();
    return [
      '''
        CREATE TRIGGER compensation_${opTypeLower}_${namespace}_${tableName}_${childKey}_into_oplog
          AFTER $opType ON "$namespace"."$tableName"
          WHEN 1 = (SELECT flag from _electric_trigger_settings WHERE namespace = '$namespace' AND tablename = '$tableName') AND
               1 = (SELECT value from _electric_meta WHERE key = 'compensations')
        BEGIN
          INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
          SELECT '$fkTableNamespace', '$fkTableName', 'COMPENSATION', ${createPKJsonObject(joinedFkPKs)}, json_object($joinedFkPKs), NULL, NULL
          FROM "$fkTableNamespace"."$fkTableName" WHERE "${foreignKey.parentKey}" = new."${foreignKey.childKey}";
        END;
      ''',
    ];
  }

  @override
  String removeDeletedShadowRows(
    QualifiedTablename oplogTable,
    QualifiedTablename shadowTable,
  ) {
    final oplog = '"${oplogTable.namespace}"."${oplogTable.tablename}"';
    final shadow = '"${shadowTable.namespace}"."${shadowTable.tablename}"';
    // We do an inner join in a CTE instead of a `WHERE EXISTS (...)`
    // since this is not reliant on re-executing a query
    // for every row in the shadow table, but uses a PK join instead.
    return '''
      WITH _to_be_deleted (rowid) AS (
        SELECT shadow.rowid
          FROM $oplog AS op
          INNER JOIN $shadow AS shadow
            ON shadow.namespace = op.namespace AND shadow.tablename = op.tablename AND shadow.primaryKey = op.primaryKey
          WHERE op.timestamp = ?
          GROUP BY op.namespace, op.tablename, op.primaryKey
          HAVING op.rowid = max(op.rowid) AND op.optype = 'DELETE'
      )
  
      DELETE FROM $shadow
      WHERE rowid IN _to_be_deleted
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
      INSERT OR REPLACE INTO $shadow (namespace, tablename, primaryKey, tags)
      SELECT namespace, tablename, primaryKey, ?
        FROM $oplog AS op
        WHERE timestamp = ?
        GROUP BY namespace, tablename, primaryKey
        HAVING rowid = max(rowid) AND optype != 'DELETE'
    ''';
  }

  String createJsonObject(String rows) {
    return 'json_object($rows)';
  }

  // removes null values from the JSON
  // to be consistent with PG behaviour
  String removeSpaceAndNullValuesFromJson(String json) {
    return "json_patch('{}', $json)";
  }

  String createPKJsonObject(String rows) {
    return removeSpaceAndNullValuesFromJson(createJsonObject(rows));
  }
}
