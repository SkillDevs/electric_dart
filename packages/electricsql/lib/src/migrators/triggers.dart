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

class Table {
  String tableName;
  String namespace;
  List<String> columns;
  List<String> primary;
  List<ForeignKey> foreignKeys;

  Table({
    required this.tableName,
    required this.namespace,
    required this.columns,
    required this.primary,
    required this.foreignKeys,
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

  final newPKs = joinColsForJSON(primary, 'new');
  final oldPKs = joinColsForJSON(primary, 'old');
  final newRows = joinColsForJSON(columns, 'new');
  final oldRows = joinColsForJSON(columns, 'old');

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
      BEFORE UPDATE ON $tableFullName
    BEGIN
      SELECT
        CASE
          ${primary.map((col) => "WHEN old.$col != new.$col THEN\n\t\tRAISE (ABORT, 'cannot change the value of column $col as it belongs to the primary key')").join('\n')}
        END;
    END;
    ''',
    '''

    -- Triggers that add INSERT, UPDATE, DELETE operation to the _opslog table
    DROP TRIGGER IF EXISTS insert_${namespace}_${tableName}_into_oplog;
    ''',
    '''

    CREATE TRIGGER insert_${namespace}_${tableName}_into_oplog
       AFTER INSERT ON $tableFullName
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
       AFTER UPDATE ON $tableFullName
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
       AFTER DELETE ON $tableFullName
       WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == '$tableFullName')
    BEGIN
      INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
      VALUES ('$namespace', '$tableName', 'DELETE', json_object($oldPKs), NULL, json_object($oldRows), NULL);
    END;
    ''',
  ].map(Statement.new).toList();
}

/// Generates triggers for compensations for all foreign keys in the provided table.
/// @param tableFullName Full name of the table.
/// @param table The corresponding table.
/// @param tables Map of all tables (needed to look up the tables that are pointed at by FKs).
/// @returns An array of SQLite statements that add the necessary compensation triggers.
List<Statement> generateCompensationTriggers(
  TableFullName tableFullName,
  Table table,
) {
  final tableName = table.tableName;
  final namespace = table.namespace;
  final foreignKeys = table.foreignKeys;

  List<Statement> makeTriggers(ForeignKey foreignKey) {
    final childKey = foreignKey.childKey;

    const fkTableNamespace =
        'main'; // currently, Electric always uses the 'main' namespace
    final fkTableName = foreignKey.table;
    final fkTablePK =
        foreignKey.parentKey; // primary key of the table pointed at by the FK.
    final joinedFkPKs = joinColsForJSON([fkTablePK], null);

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
        AFTER INSERT ON $tableFullName
        WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == '$fkTableNamespace.$fkTableName') AND
             1 == (SELECT value from _electric_meta WHERE key == 'compensations')
      BEGIN
        INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
        SELECT '$fkTableNamespace', '$fkTableName', 'UPDATE', json_object($joinedFkPKs), json_object($joinedFkPKs), NULL, NULL
        FROM $fkTableNamespace.$fkTableName WHERE ${foreignKey.parentKey} = new.${foreignKey.childKey};
      END;
      ''',
      'DROP TRIGGER IF EXISTS compensation_update_${namespace}_${tableName}_${foreignKey.childKey}_into_oplog;',
      '''
      CREATE TRIGGER compensation_update_${namespace}_${tableName}_${foreignKey.childKey}_into_oplog
         AFTER UPDATE ON $namespace.$tableName
         WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == '$fkTableNamespace.$fkTableName') AND
              1 == (SELECT value from _electric_meta WHERE key == 'compensations')
      BEGIN
        INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
        SELECT '$fkTableNamespace', '$fkTableName', 'UPDATE', json_object($joinedFkPKs), json_object($joinedFkPKs), NULL, NULL
        FROM $fkTableNamespace.$fkTableName WHERE ${foreignKey.parentKey} = new.${foreignKey.childKey};
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
  final fkTriggers =
      generateCompensationTriggers(tableFullName, table); //, tables)
  return [...oplogTriggers, ...fkTriggers];
}

/// Generates triggers for all the provided tables.
/// @param tables - Dictionary mapping full table names to the corresponding tables.
/// @returns An array of SQLite statements that add the necessary oplog and compensation triggers for all tables.
List<Statement> generateTriggers(Tables tables) {
  final List<Statement> tableTriggers = [];
  tables.forEach((tableFullName, table) {
    final triggers = generateTableTriggers(tableFullName, table); //, tables)
    tableTriggers.addAll(triggers);
  });

  final List<Statement> stmts = [
    Statement('DROP TABLE IF EXISTS _electric_trigger_settings;'),
    Statement(
      'CREATE TABLE _electric_trigger_settings(tablename TEXT PRIMARY KEY, flag INTEGER);',
    ),
    ...tableTriggers
  ];

  return stmts;
}

String joinColsForJSON(List<String> cols, String? target) {
  if (target == null) {
    return (cols..sort()).map((col) => "'$col', $col").join(', ');
  } else {
    return (cols..sort()).map((col) => "'$col', $target.$col").join(', ');
  }
}
