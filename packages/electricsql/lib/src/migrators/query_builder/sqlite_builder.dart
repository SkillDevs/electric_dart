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
  String get deferOrDisableFKsForTx => 'PRAGMA defer_foreign_keys = ON;';

  @override
  String get paramSign => '?';

  List<String> get metaTables => [
        'sqlite_schema',
        'sqlite_sequence',
        'sqlite_temp_schema',
      ];

  @override
  List<Statement> batchedInsertOrReplace(
    QualifiedTablename table,
    List<String> columns,
    List<Map<String, Object?>> records,
    List<String> conflictCols,
    List<String> updateCols,
    int maxSqlParameters,
  ) {
    final baseSql =
        'INSERT OR REPLACE INTO $table (${columns.join(', ')}) VALUES ';
    return prepareInsertBatchedStatements(
      baseSql,
      columns,
      records,
      maxSqlParameters,
    );
  }

  @override
  Statement countTablesIn(List<String> tableNames) {
    final sql = '''
      SELECT count(name) as "count" FROM sqlite_master
        WHERE type='table'
        AND name IN (${tableNames.map((_) => '?').join(', ')})
    ''';
    return Statement(
      sql,
      tableNames,
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
    QualifiedTablename table,
    List<String> pk,
  ) {
    final namespace = table.namespace;
    final tablename = table.tablename;
    return [
      '''
CREATE TRIGGER update_ensure_${namespace}_${tablename}_primarykey
  BEFORE UPDATE ON $table
BEGIN
  SELECT
    CASE
      ${pk.map(
            (col) => '''
WHEN old."$col" != new."$col" THEN
      \t\tRAISE (ABORT, 'cannot change the value of column $col as it belongs to the primary key')''',
          ).join('\n')}
    END;
END;''',
    ];
  }

  @override
  List<String> createOplogTrigger(
    SqlOpType opType,
    QualifiedTablename table,
    String newPKs,
    String newRows,
    String oldRows,
  ) {
    final namespace = table.namespace;
    final tableName = table.tablename;

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
  AFTER ${opType.text} ON $table
  WHEN 1 = (SELECT flag from _electric_trigger_settings WHERE namespace = '$namespace' AND tablename = '$tableName')
BEGIN
  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
  VALUES ('$namespace', '$tableName', '${opType.text}', $pk, $newRecord, $oldRecord, NULL);
END;''',
    ];
  }

  @override
  String dropTriggerIfExists(
    String triggerName,
    QualifiedTablename table,
  ) {
    return 'DROP TRIGGER IF EXISTS $triggerName;';
  }

  @override
  Statement getLocalTableNames([List<String> notIn = const []]) {
    final ignore = [...metaTables];
    ignore.addAll(notIn);

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
  Statement getTableInfo(QualifiedTablename table) {
    return Statement(
      'SELECT name, type, "notnull", dflt_value, pk FROM pragma_table_info(?)',
      [table.tablename],
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
    QualifiedTablename table,
    List<String> columns,
    List<Object?> values,
  ) {
    return Statement(
      '''
        INSERT OR IGNORE INTO $table (${columns.join(', ')})
          VALUES (${columns.map((_) => '?').join(', ')});
      ''',
      values,
    );
  }

  @override
  Statement insertOrReplace(
    QualifiedTablename table,
    List<String> columns,
    List<Object?> values,
    List<String> conflictCols,
    List<String> updateCols,
  ) {
    return Statement(
      '''
        INSERT OR REPLACE INTO $table (${columns.join(', ')})
        VALUES (${columns.map((_) => '?').join(', ')})
      ''',
      values,
    );
  }

  @override
  Statement insertOrReplaceWith(
    QualifiedTablename table,
    List<String> columns,
    List<Object?> values,
    List<String> conflictCols,
    List<String> updateCols,
    List<Object?> updateVals,
  ) {
    final insertOrReplaceRes = insertOrReplace(
      table,
      columns,
      values,
      conflictCols,
      updateCols,
    );
    return Statement(
      '${insertOrReplaceRes.sql} ON CONFLICT DO UPDATE SET ${updateCols.map((col) => '$col = ?').join(', ')}',
      [...insertOrReplaceRes.args!, ...updateVals],
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
  String setTriggerSetting(QualifiedTablename table, int value) {
    return "INSERT OR IGNORE INTO _electric_trigger_settings (namespace, tablename, flag) VALUES ('${table.namespace}', '${table.tablename}', $value);";
  }

  @override
  String sqliteOnly(String query) {
    return query;
  }

  @override
  Statement tableExists(QualifiedTablename table) {
    return Statement(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      [table.tablename],
    );
  }

  @override
  String toHex(String column) {
    return 'hex($column)';
  }

  @override
  List<String> createFkCompensationTrigger(
    String opType,
    QualifiedTablename table,
    String childKey,
    QualifiedTablename fkTable,
    String joinedFkPKs,
    ForeignKey foreignKey,
  ) {
    final namespace = table.namespace;
    final tableName = table.tablename;
    final fkTableNamespace = fkTable.namespace;
    final fkTableName = fkTable.tablename;

    final opTypeLower = opType.toLowerCase();
    return [
      '''
        CREATE TRIGGER compensation_${opTypeLower}_${namespace}_${tableName}_${childKey}_into_oplog
          AFTER $opType ON $table
          WHEN 1 = (SELECT flag from _electric_trigger_settings WHERE namespace = '$namespace' AND tablename = '$tableName') AND
               1 = (SELECT value from _electric_meta WHERE key = 'compensations')
        BEGIN
          INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
          SELECT '$fkTableNamespace', '$fkTableName', 'COMPENSATION', ${createPKJsonObject(joinedFkPKs)}, json_object($joinedFkPKs), NULL, NULL
          FROM $fkTable WHERE "${foreignKey.parentKey}" = new."${foreignKey.childKey}";
        END;
      ''',
    ];
  }

  @override
  String removeDeletedShadowRows(
    QualifiedTablename oplog,
    QualifiedTablename shadow,
  ) {
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
    QualifiedTablename oplog,
    QualifiedTablename shadow,
  ) {
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
