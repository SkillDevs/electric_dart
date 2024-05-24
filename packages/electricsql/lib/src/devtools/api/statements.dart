import 'package:electricsql/electricsql.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql/src/devtools/shared.dart';
import 'package:electricsql/util.dart';

const kSqliteGetTables = '''
SELECT name, sql FROM sqlite_master
WHERE type='table'
AND name NOT LIKE 'sqlite_%'
''';

const kSqliteGetDbTables = '''
$kSqliteGetTables
AND name NOT LIKE '_electric_%'
''';

const kSqliteGetElectricTables = '''
$kSqliteGetTables
AND name LIKE '_electric_%'
''';

const kPgGetTables = '''
SELECT table_name AS name FROM information_schema.tables
WHERE table_schema='public'
AND table_name NOT LIKE 'pg_%'
''';
const kPgGetDbTables = '''
$kPgGetTables
AND table_name NOT LIKE '_electric_%'
''';

const kPgGetElectricTables = '''
$kPgGetTables
AND table_name LIKE '_electric_%'
''';

Future<SqlDialect> getSqlDialect(
  DatabaseAdapter adapter,
) async {
  return switch (adapter.dialect) {
    Dialect.sqlite => SqlDialect.sqlite,
    Dialect.postgres => SqlDialect.postgres,
  };
}

Future<List<DbTableInfo>> genericGetDbTables(
  DatabaseAdapter adapter,
  SqlDialect dialect,
) async {
  final tablesRaw = await adapter.query(
    Statement(
      dialect == SqlDialect.sqlite ? kSqliteGetDbTables : kPgGetDbTables,
    ),
  );

  return Future.wait<DbTableInfo>(
    tablesRaw.map((tbl) async {
      final tableName = tbl['name']! as String;

      return DbTableInfo(
        name: tableName,
        sql: tbl['sql'] as String? ?? '',
        columns: await getTableColumns(adapter, dialect, tableName),
      );
    }),
  );
}

Future<List<DbTableInfo>> genericGetElectricTables(
  DatabaseAdapter adapter,
  SqlDialect dialect,
) async {
  final tablesRaw = await adapter.query(
    Statement(
      dialect == SqlDialect.sqlite
          ? kSqliteGetElectricTables
          : kPgGetElectricTables,
    ),
  );

  return Future.wait<DbTableInfo>(
    tablesRaw.map((tbl) async {
      final tableName = tbl['name']! as String;

      return DbTableInfo(
        name: tableName,
        sql: tbl['sql'] as String? ?? '',
        columns: await getTableColumns(adapter, dialect, tableName),
      );
    }),
  );
}

Future<List<TableColumn>> getTableColumns(
  DatabaseAdapter adapter,
  SqlDialect dialect,
  String tableName,
) async {
  final columns = await adapter.query(
    Statement(
      dialect == SqlDialect.sqlite
          ? 'PRAGMA table_info($tableName)'
          : '''
    SELECT
      column_name as name,
      data_type as type,
      (is_nullable = 'NO') as notnull
    FROM information_schema.columns
    WHERE table_name = '$tableName';''',
    ),
  );
  return columns.map((c) {
    final notNullRaw = c['notnull'];
    final notNull = notNullRaw != null &&
        (notNullRaw is bool ? notNullRaw : notNullRaw == 1);
    return TableColumn(
      name: c['name']! as String,
      type: c['type']! as String,
      nullable: !notNull,
    );
  }).toList();
}
