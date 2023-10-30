import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/util/types.dart';

// TODO: Improve this code once with Migrator and consider simplifying oplog.
Future<RelationsCache> inferRelationsFromSQLite(
  DatabaseAdapter adapter,
  SatelliteOpts opts,
) async {
  final tableNames = await _getLocalTableNames(adapter, opts);
  final RelationsCache relations = {};

  int id = 0;
  const schema = 'public'; // TODO
  for (final table in tableNames) {
    final tableName = table.name;
    const sql = 'SELECT * FROM pragma_table_info(?)';
    final args = [tableName];
    final columnsForTable = await adapter.query(Statement(sql, args));
    if (columnsForTable.isEmpty) {
      continue;
    }
    final Relation relation = Relation(
      id: id++,
      schema: schema,
      table: tableName,
      tableType: SatRelation_RelationType.TABLE,
      columns: [],
    );
    for (final c in columnsForTable) {
      relation.columns.add(
        RelationColumn(
          name: c['name']! as String,
          type: c['type']! as String,
          isNullable: (c['notnull']! as int) == 0,
          primaryKey: (c['pk']! as int) > 0,
        ),
      );
    }
    relations[tableName] = relation;
  }

  return relations;
}

Future<List<({String name})>> _getLocalTableNames(
  DatabaseAdapter adapter,
  SatelliteOpts opts,
) async {
  final notIn = <String>[
    opts.metaTable.tablename,
    opts.migrationsTable.tablename,
    opts.oplogTable.tablename,
    opts.triggersTable.tablename,
    opts.shadowTable.tablename,
    'sqlite_schema',
    'sqlite_sequence',
    'sqlite_temp_schema',
  ];

  final tables = '''
      SELECT name FROM sqlite_master
        WHERE type = 'table'
          AND name NOT IN (${notIn.map((_) => '?').join(',')})
    ''';
  final tableNames = await adapter.query(Statement(tables, notIn));
  return tableNames.map((row) => (name: row['name']! as String)).toList();
}
