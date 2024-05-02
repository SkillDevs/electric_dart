import 'package:collection/collection.dart';
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
    String? schema,
  ) {
    schema ??= defaultNamespace;
    final baseSql =
        '''INSERT INTO "$schema"."$table" (${columns.map(quote).join(', ')}) VALUES ''';
    final statements = prepareInsertBatchedStatements(
      baseSql,
      columns,
      records,
      maxSqlParameters,
    );
    return statements
        .map(
          (stmt) => Statement(
            '''
        ${stmt.sql}
        ON CONFLICT (${conflictCols.map(quote).join(', ')}) DO UPDATE
        SET ${updateCols.map((col) => '${quote(col)} = EXCLUDED.${quote(col)}').join(', ')};
      ''',
            stmt.args,
          ),
        )
        .toList();
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

    final opTypeLower = opType.toLowerCase();

    return [
      '''
        CREATE OR REPLACE FUNCTION compensation_${opTypeLower}_${namespace}_${tableName}_${childKey}_into_oplog_function()
        RETURNS TRIGGER AS \$\$
        BEGIN
          DECLARE
            flag_value INTEGER;
            meta_value INTEGER;
          BEGIN
            SELECT flag INTO flag_value FROM "$namespace"._electric_trigger_settings WHERE namespace = '$namespace' AND tablename = '$tableName';
    
            SELECT value INTO meta_value FROM "$namespace"._electric_meta WHERE key = 'compensations';
    
            IF flag_value = 1 AND meta_value = 1 THEN
              INSERT INTO "$namespace"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
              SELECT
                '$fkTableNamespace',
                '$fkTableName',
                'COMPENSATION',
                ${removeSpaceAndNullValuesFromJson(createPKJsonObject(joinedFkPKs))},
                jsonb_build_object($joinedFkPKs),
                NULL,
                NULL
              FROM "$fkTableNamespace"."$fkTableName"
              WHERE "${foreignKey.parentKey}" = NEW."${foreignKey.childKey}";
            END IF;
    
            RETURN NEW;
          END;
        END;
        \$\$ LANGUAGE plpgsql;
        ''',
      '''
          CREATE TRIGGER compensation_${opTypeLower}_${namespace}_${tableName}_${childKey}_into_oplog
            AFTER $opType ON "$namespace"."$tableName"
              FOR EACH ROW
                EXECUTE FUNCTION compensation_${opTypeLower}_${namespace}_${tableName}_${childKey}_into_oplog_function();
        ''',
    ];
  }

  @override
  String createIndex(
    String indexName,
    QualifiedTablename onTable,
    List<String> columns,
  ) {
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

    return [
      '''
        CREATE OR REPLACE FUNCTION update_ensure_${namespace}_${tablename}_primarykey_function()
        RETURNS TRIGGER AS \$\$
        BEGIN
          ${pk.map(
            (col) => '''
IF OLD."$col" IS DISTINCT FROM NEW."$col" THEN
            RAISE EXCEPTION 'Cannot change the value of column $col as it belongs to the primary key';
          END IF;''',
          ).join('\n')}
          RETURN NEW;
        END;
        \$\$ LANGUAGE plpgsql;
      ''',
      '''
        CREATE TRIGGER update_ensure_${namespace}_${tablename}_primarykey
          BEFORE UPDATE ON "$namespace"."$tablename"
            FOR EACH ROW
              EXECUTE FUNCTION update_ensure_${namespace}_${tablename}_primarykey_function();
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

    final opTypeLower = opType.text.toLowerCase();
    final pk = createPKJsonObject(newPKs);
    // Update has both the old and the new row
    // Delete only has the old row
    final newRecord =
        opType == SqlOpType.delete ? 'NULL' : createJsonbObject(newRows);
    // Insert only has the new row
    final oldRecord =
        opType == SqlOpType.insert ? 'NULL' : createJsonbObject(oldRows);

    return [
      '''
        CREATE OR REPLACE FUNCTION ${opTypeLower}_${namespace}_${tableName}_into_oplog_function()
        RETURNS TRIGGER AS \$\$
        BEGIN
          DECLARE
            flag_value INTEGER;
          BEGIN
            -- Get the flag value from _electric_trigger_settings
            SELECT flag INTO flag_value FROM "$namespace"._electric_trigger_settings WHERE namespace = '$namespace' AND tablename = '$tableName';
    
            IF flag_value = 1 THEN
              -- Insert into _electric_oplog
              INSERT INTO "$namespace"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
              VALUES (
                '$namespace',
                '$tableName',
                '$opType',
                $pk,
                $newRecord,
                $oldRecord,
                NULL
              );
            END IF;
    
            RETURN NEW;
          END;
        END;
        \$\$ LANGUAGE plpgsql;
      ''',
      '''
        CREATE TRIGGER ${opTypeLower}_${namespace}_${tableName}_into_oplog
          AFTER $opType ON "$namespace"."$tableName"
            FOR EACH ROW
              EXECUTE FUNCTION ${opTypeLower}_${namespace}_${tableName}_into_oplog_function();
      ''',
    ];
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
    return 'DROP TRIGGER IF EXISTS $triggerName ON "$namespace"."$tablename";';
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
  String get getVersion => 'SELECT version();';

  @override
  String hexValue(String hexString) {
    return "'\\x$hexString'";
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
        INSERT INTO "$schema"."$table" (${columns.map(quote).join(', ')})
          VALUES (${columns.mapIndexed((i, _) => '\$${i + 1}').join(', ')})
          ON CONFLICT DO NOTHING;
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
        INSERT INTO "$schema"."$table" (${columns.map(quote).join(', ')})
          VALUES (${columns.mapIndexed((i, _) => '\$${i + 1}').join(', ')})
        ON CONFLICT (${conflictCols.map(quote).join(', ')}) DO UPDATE
          SET ${updateCols.map((col) => '${quote(col)} = EXCLUDED.${quote(col)}').join(', ')};
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
    return Statement(
      '''
        INSERT INTO "$schema"."$table" (${columns.map(quote).join(', ')})
          VALUES (${columns.mapIndexed((i, _) => "\$${i + 1}").join(', ')})
        ON CONFLICT (${conflictCols.map(quote).join(', ')}) DO UPDATE
          SET ${updateCols.mapIndexed((i, col) => '${quote(col)} = \$${columns.length + i + 1}').join(', ')};
      ''',
      [...values, ...updateVals],
    );
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
    QualifiedTablename oplogTable,
    QualifiedTablename shadowTable,
  ) {
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

    return '''
INSERT INTO "$namespace"."_electric_trigger_settings" ("namespace", "tablename", "flag")
VALUES ('$namespace', '$tableName', $value)
ON CONFLICT DO NOTHING;
''';
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
    return "encode($column::bytea, 'hex')";
  }

  // This creates a JSON object that is equivalent
  // to the JSON objects created by SQLite
  // in that it does not re-order the keys
  // and removes whitespaces between keys and values.
  String createPKJsonObject(String rows) {
    // `json_build_object` introduces whitespaces
    // e.g. `{"a" : 5, "b" : 6}`
    // But the json produced by SQLite is `{"a":5,"b":6}`.
    // So this may lead to problems because we use this JSON string
    // of the primary key to compare local and remote entries.
    // But the changes for the same PK would be considered to be different PKs
    // if e.g. the local change is PG and the remote change is SQLite.
    // We use `json_strip_nulls` on the PK as it removes the whitespaces.
    // It also removes `null` values from the PK. Therefore, it is important
    // that the SQLite oplog triggers also remove `null` values from the PK.
    return 'json_strip_nulls(json_build_object($rows))';
  }

  String createJsonbObject(String rows) {
    return 'jsonb_build_object($rows)';
  }

  // removes null values from the json object
  // but most importantly also removes whitespaces introduced by `jsonb_build_object`
  String removeSpaceAndNullValuesFromJson(String j) {
    return 'json_strip_nulls($j)';
  }
}
