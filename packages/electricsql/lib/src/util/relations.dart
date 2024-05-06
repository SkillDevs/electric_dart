import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/util.dart';

// TODO: Improve this code once with Migrator and consider simplifying oplog.
Future<RelationsCache> inferRelationsFromDb(
  DatabaseAdapter adapter,
  SatelliteOpts opts,
  QueryBuilder builder,
) async {
  final tableNames = await _getLocalTableNames(adapter, opts, builder);
  final RelationsCache relations = {};

  int id = 0;
  for (final table in tableNames) {
    final tableName = table.name;
    final columnsForTable = await adapter.query(
      builder.getTableInfo(
        QualifiedTablename(builder.defaultNamespace, tableName),
      ),
    );
    if (columnsForTable.isEmpty) {
      continue;
    }
    final Relation relation = Relation(
      id: id++,
      // schema needs to be 'public' because these relations are used
      // by the Satellite process and client to replicate changes to Electric
      // and merge incoming changes from Electric, and those use the 'public' namespace.
      schema: 'public',
      table: tableName,
      tableType: SatRelation_RelationType.TABLE,
      columns: [],
    );
    for (final c in columnsForTable) {
      final int pkColVal = c['pk']! as int;
      relation.columns.add(
        RelationColumn(
          name: c['name']! as String,
          type: c['type']! as String,
          isNullable: (c['notnull']! as int) == 0,
          primaryKey: pkColVal > 0 ? pkColVal : null,
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
  QueryBuilder builder,
) async {
  final notIn = <String>[
    opts.metaTable.tablename,
    opts.migrationsTable.tablename,
    opts.oplogTable.tablename,
    opts.triggersTable.tablename,
    opts.shadowTable.tablename,
  ];

  final rows = await adapter.query(builder.getLocalTableNames(notIn));
  return rows.map((row) => (name: row['name']! as String)).toList();
}
