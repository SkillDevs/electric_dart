import 'package:electricsql/src/util/types.dart';

class ForeignKey {
  String table;
  String childKey;
  String parentKey;

  ForeignKey({
    required this.table,
    required this.childKey,
    required this.parentKey,
  });
}

typedef ColumnName = String;
typedef SQLiteType = String;
typedef PgTypeStr = String;
typedef ColumnType = ({SQLiteType sqliteType, PgTypeStr pgType});
typedef ColumnTypes = Map<ColumnName, ColumnType>;

class Table {
  String tableName;
  String namespace;
  List<ColumnName> columns;
  List<ColumnName> primary;
  List<ForeignKey> foreignKeys;
  ColumnTypes columnTypes;

  Table({
    required this.tableName,
    required this.namespace,
    required this.columns,
    required this.primary,
    required this.foreignKeys,
    required this.columnTypes,
  });
}

typedef TableFullName = String;
typedef Tables = Map<TableFullName, Table>;

/// Generates the triggers Satellite needs for the given table.
/// Assumes that the necessary meta tables already exist.
/// @param tableFullName - Full name of the table for which to generate triggers.
/// @param table - A new or existing table for which to create/update the triggers.
/// @returns An array of SQLite statements that add the necessary oplog triggers.
///
/// @remarks
/// We return an array of SQL statements because the DB drivers
/// do not accept queries containing more than one SQL statement.
List<Statement> generateOplogTriggers(
  TableFullName tableFullName,
  Table table,
) {
  final tableName = table.tableName;
  final primary = table.primary;
  final columns = table.columns;
  final namespace = table.namespace;
  final columnTypes = table.columnTypes;

  final newPKs = joinColsForJSON(primary, columnTypes, 'new');
  final oldPKs = joinColsForJSON(primary, columnTypes, 'old');
  final newRows = joinColsForJSON(columns, columnTypes, 'new');
  final oldRows = joinColsForJSON(columns, columnTypes, 'old');

  return <String>[
    '''

    -- Toggles for turning the triggers on and off
    INSERT OR IGNORE INTO _electric_trigger_settings(tablename,flag) VALUES ('$tableFullName', 1);
    ''',
    '''

    /* Triggers for table $tableName */

    -- ensures primary key is immutable
    DROP TRIGGER IF EXISTS update_ensure_${namespace}_${tableName}_primarykey;
    ''',
    '''

    CREATE TRIGGER update_ensure_${namespace}_${tableName}_primarykey
      BEFORE UPDATE ON "$namespace"."$tableName"
    BEGIN
      SELECT
        CASE
          ${primary.map((col) => "WHEN old.\"$col\" != new.\"$col\" THEN\n\t\tRAISE (ABORT, 'cannot change the value of column $col as it belongs to the primary key')").join('\n')}
        END;
    END;
    ''',
    '''

    -- Triggers that add INSERT, UPDATE, DELETE operation to the _opslog table
    DROP TRIGGER IF EXISTS insert_${namespace}_${tableName}_into_oplog;
    ''',
    '''

    CREATE TRIGGER insert_${namespace}_${tableName}_into_oplog
       AFTER INSERT ON "$namespace"."$tableName"
       WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == '$tableFullName')
    BEGIN
      INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
      VALUES ('$namespace', '$tableName', 'INSERT', json_object($newPKs), json_object($newRows), NULL, NULL);
    END;
    ''',
    '''

    DROP TRIGGER IF EXISTS update_${namespace}_${tableName}_into_oplog;
    ''',
    '''

    CREATE TRIGGER update_${namespace}_${tableName}_into_oplog
       AFTER UPDATE ON "$namespace"."$tableName"
       WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == '$tableFullName')
    BEGIN
      INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
      VALUES ('$namespace', '$tableName', 'UPDATE', json_object($newPKs), json_object($newRows), json_object($oldRows), NULL);
    END;
    ''',
    '''

    DROP TRIGGER IF EXISTS delete_${namespace}_${tableName}_into_oplog;
    ''',
    '''

    CREATE TRIGGER delete_${namespace}_${tableName}_into_oplog
       AFTER DELETE ON "$namespace"."$tableName"
       WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == '$tableFullName')
    BEGIN
      INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
      VALUES ('$namespace', '$tableName', 'DELETE', json_object($oldPKs), NULL, json_object($oldRows), NULL);
    END;
    ''',
  ].map(Statement.new).toList();
}

/// Generates triggers for compensations for all foreign keys in the provided table.
///
/// Compensation is recorded as a SatOpCompensation messaage. The entire reason
/// for it existing is to maybe revive the row if it has been deleted, so we need
/// correct tags.
///
/// The compensation update contains _just_ the primary keys, no other columns are present.
///
/// @param tableFullName Full name of the table.
/// @param table The corresponding table.
/// @param tables Map of all tables (needed to look up the tables that are pointed at by FKs).
/// @returns An array of SQLite statements that add the necessary compensation triggers.
List<Statement> generateCompensationTriggers(Table table) {
  final tableName = table.tableName;
  final namespace = table.namespace;
  final foreignKeys = table.foreignKeys;
  final columnTypes = table.columnTypes;

  List<Statement> makeTriggers(ForeignKey foreignKey) {
    final childKey = foreignKey.childKey;

    const fkTableNamespace =
        'main'; // currently, Electric always uses the 'main' namespace
    final fkTableName = foreignKey.table;
    final fkTablePK =
        foreignKey.parentKey; // primary key of the table pointed at by the FK.
    final joinedFkPKs = joinColsForJSON([fkTablePK], columnTypes, null);

    return <String>[
      '''
      -- Triggers for foreign key compensations
      DROP TRIGGER IF EXISTS compensation_insert_${namespace}_${tableName}_${childKey}_into_oplog;''',
      // The compensation trigger inserts a row in `_electric_oplog` if the row pointed at by the FK exists
      // The way how this works is that the values for the row are passed to the nested SELECT
      // which will return those values for every record that matches the query
      // which can be at most once since we filter on the foreign key which is also the primary key and thus is unique.
      '''
      CREATE TRIGGER compensation_insert_${namespace}_${tableName}_${childKey}_into_oplog
        AFTER INSERT ON "$namespace"."$tableName"
        WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == '$fkTableNamespace.$fkTableName') AND
             1 == (SELECT value from _electric_meta WHERE key == 'compensations')
      BEGIN
        INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
        SELECT '$fkTableNamespace', '$fkTableName', 'COMPENSATION', json_object($joinedFkPKs), json_object($joinedFkPKs), NULL, NULL
        FROM "$fkTableNamespace"."$fkTableName" WHERE "${foreignKey.parentKey}" = new."${foreignKey.childKey}";
      END;
      ''',
      'DROP TRIGGER IF EXISTS compensation_update_${namespace}_${tableName}_${foreignKey.childKey}_into_oplog;',
      '''
      CREATE TRIGGER compensation_update_${namespace}_${tableName}_${foreignKey.childKey}_into_oplog
         AFTER UPDATE ON "$namespace"."$tableName"
         WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == '$fkTableNamespace.$fkTableName') AND
              1 == (SELECT value from _electric_meta WHERE key == 'compensations')
      BEGIN
        INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
        SELECT '$fkTableNamespace', '$fkTableName', 'COMPENSATION', json_object($joinedFkPKs), json_object($joinedFkPKs), NULL, NULL
        FROM "$fkTableNamespace"."$fkTableName" WHERE "${foreignKey.parentKey}" = new."${foreignKey.childKey}";
      END;
      ''',
    ].map(Statement.new).toList();
  }

  final fkTriggers = foreignKeys.map((fk) => makeTriggers(fk));

  return fkTriggers.expand((l) => l).toList();
}

/// Generates the oplog triggers and compensation triggers for the provided table.
/// @param tableFullName - Full name of the table for which to create the triggers.
/// @param tables - Dictionary mapping full table names to the corresponding tables.
/// @returns An array of SQLite statements that add the necessary oplog and compensation triggers.
List<Statement> generateTableTriggers(
  TableFullName tableFullName,
  Table table,
) {
  final oplogTriggers = generateOplogTriggers(tableFullName, table);
  final fkTriggers = generateCompensationTriggers(table);
  return [...oplogTriggers, ...fkTriggers];
}

/// Generates triggers for all the provided tables.
/// @param tables - Dictionary mapping full table names to the corresponding tables.
/// @returns An array of SQLite statements that add the necessary oplog and compensation triggers for all tables.
List<Statement> generateTriggers(Tables tables) {
  final List<Statement> tableTriggers = [];
  tables.forEach((tableFullName, table) {
    final triggers = generateTableTriggers(tableFullName, table);
    tableTriggers.addAll(triggers);
  });

  final List<Statement> stmts = [
    Statement('DROP TABLE IF EXISTS _electric_trigger_settings;'),
    Statement(
      'CREATE TABLE _electric_trigger_settings(tablename TEXT PRIMARY KEY, flag INTEGER);',
    ),
    ...tableTriggers,
  ];

  return stmts;
}

/// Joins the column names and values into a string of pairs of the form `'col1', val1, 'col2', val2, ...`
/// that can be used to build a JSON object in a SQLite `json_object` function call.
/// Values of type REAL are cast to text to avoid a bug in SQLite's `json_object` function (see below).
/// Similarly, values of type INT8 (i.e. BigInts) are cast to text because JSON does not support BigInts.
///
/// NOTE: There is a bug with SQLite's `json_object` function up to version 3.41.2
///       that causes it to return an invalid JSON object if some value is +Infinity or -Infinity.
/// @example
/// sqlite> SELECT json_object('a',2e370,'b',-3e380);
/// {"a":Inf,"b":-Inf}
///
/// The returned JSON is not valid because JSON does not support `Inf` nor `-Inf`.
/// @example
/// sqlite> SELECT json_valid((SELECT json_object('a',2e370,'b',-3e380)));
/// 0
///
/// This is fixed in version 3.42.0 and on:
/// @example
/// sqlite> SELECT json_object('a',2e370,'b',-3e380);
/// {"a":9e999,"b":-9e999}
///
/// The returned JSON now is valid, the numbers 9e999 and -9e999
/// are out of range of floating points and thus will be converted
/// to `Infinity` and `-Infinity` when parsed with `JSON.parse`.
///
/// Nevertheless version SQLite version 3.42.0 is very recent (May 2023)
/// and users may be running older versions so we want to support them.
/// Therefore we introduce the following workaround:
/// @example
/// sqlite> SELECT json_object('a', cast(2e370 as TEXT),'b', cast(-3e380 as TEXT));
/// {"a":"Inf","b":"-Inf"}
///
/// By casting the values to TEXT, infinity values are turned into their string representation.
/// As such, the resulting JSON is valid.
/// This means that the values will be stored as strings in the oplog,
/// thus, we must be careful when parsing the oplog to convert those values back to their numeric type.
///
/// For reference:
/// - https://discord.com/channels/933657521581858818/1163829658236760185
/// - https://www.sqlite.org/src/info/b52081d0acd07dc5bdb4951a3e8419866131965260c1e3a4c9b6e673bfe3dfea
///
/// @param cols The column names
/// @param target The target to use for the column values (new or old value provided by the trigger).
String joinColsForJSON(
  List<String> cols,
  ColumnTypes colTypes,
  String? target,
) {
  // casts the value to TEXT if it is of type REAL
  // to work around the bug in SQLite's `json_object` function
  String castIfNeeded(String col, String targettedCol) {
    final tpes = colTypes[col]!;
    final sqliteType = tpes.sqliteType;
    final pgType = tpes.pgType;
    if (
        // REAL has a special handling for NaN and Infinities
        sqliteType == 'REAL' ||
            // INT8 and BIGINT encoded as string in oplog JSON
            (pgType == 'INT8' || pgType == 'BIGINT')) {
      return 'cast($targettedCol as TEXT)';
    } else {
      return targettedCol;
    }
  }

  if (target == null) {
    return (cols..sort())
        .map((col) => "'$col', ${castIfNeeded(col, '"$col"')}")
        .join(', ');
  } else {
    return (cols..sort())
        .map((col) => "'$col', ${castIfNeeded(col, '$target."$col"')}")
        .join(', ');
  }
}
