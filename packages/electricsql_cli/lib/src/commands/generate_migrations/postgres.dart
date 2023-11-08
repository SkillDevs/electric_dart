import 'package:electricsql_cli/src/commands/generate/drift_gen_opts.dart';
import 'package:electricsql_cli/src/commands/generate/prisma.dart';
import 'package:postgres/postgres.dart';

Future<DriftSchemaInfo> introspectFromPostgres(
  PostgreSQLConnection pg, {
  ElectricDriftGenOpts? genOpts,
}) async {
  final tables = await _getElectrifiedTables(pg);

  for (final table in tables) {
    final columnInfos = await _getTableColumnsInfo(pg, table);
    print(columnInfos);
  }
}

Future<List<String>> _getElectrifiedTables(PostgreSQLConnection pg) async {
  final res = await pg.query('''
SELECT table_name
FROM electric.electrified
''');

  final tables =
      res.map((e) => e.toColumnMap()['table_name'] as String).toList();
  return tables;
}

Future<List<ColumnInfo>> _getTableColumnsInfo(
  PostgreSQLConnection pg,
  String table,
) async {
  final tableColsRes = await pg.query(
    '''
SELECT *
  FROM information_schema.columns
 WHERE table_schema = 'public'
   AND table_name   = @table
''',
    substitutionValues: {
      'table': table,
    },
  );

  final tableCols = tableColsRes.map((e) => e.toColumnMap()).toList();

  final primaryKeyRes = await pg.query(
    '''
SELECT c.column_name
FROM information_schema.table_constraints tc 
JOIN information_schema.constraint_column_usage AS ccu USING (constraint_schema, constraint_name) 
JOIN information_schema.columns AS c ON c.table_schema = tc.constraint_schema
  AND tc.table_name = c.table_name AND ccu.column_name = c.column_name
WHERE constraint_type = 'PRIMARY KEY' and tc.table_name = @table
''',
    substitutionValues: {
      'table': table,
    },
  );

  final primaryKeyCols = primaryKeyRes
      .map((e) => e.toColumnMap()['column_name'] as String)
      .toSet();

  final columnInfos = tableCols.map((e) {
    final name = e['column_name'] as String;
    final udtName = e['udt_name'] as String;
    final isNullable = e['is_nullable'] as String == 'YES';
    final isPrimaryKey = primaryKeyCols.contains(name);
    return ColumnInfo(
      name: name,
      type: udtName,
      isNullable: isNullable,
      isPrimaryKey: isPrimaryKey,
    );
  }).toList();

  return columnInfos;
}

PostgreSQLConnection getPostgresConnectionFromUri(
  Uri postgresConnectUrl, {
  String? customUser,
}) {
  final dbName = postgresConnectUrl.pathSegments.first;
  final userInfo = postgresConnectUrl.userInfo;
  final splitted = userInfo.split(':');
  final user = customUser ?? splitted[0];
  final password = splitted[1];

  final effectiveHost = postgresConnectUrl.host;

  //logger.info("Using host $effectiveHost");

  final connection = PostgreSQLConnection(
    effectiveHost,
    postgresConnectUrl.port,
    dbName,
    username: user,
    password: password,
    isUnixSocket: false,
  );
  return connection;
}

class ColumnInfo {
  final String name;
  final String type;
  final bool isNullable;
  final bool isPrimaryKey;

  ColumnInfo({
    required this.name,
    required this.type,
    required this.isNullable,
    required this.isPrimaryKey,
  });

  @override
  String toString() {
    return 'ColumnInfo(name: $name, type: $type, isNullable: $isNullable, isPrimaryKey: $isPrimaryKey)';
  }
}
