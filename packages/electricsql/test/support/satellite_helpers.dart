import 'dart:convert';

import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/util/converters/helpers.dart';
import 'package:electricsql/src/util/types.dart';

typedef TableInfo = Map<String, TableSchemaBasic>;

class TableSchemaBasic {
  final List<String> primaryKey;
  final List<String> columns;

  TableSchemaBasic({required this.primaryKey, required this.columns});
}

TableInfo initTableInfo(String namespace) {
  return {
    '$namespace.parent': TableSchemaBasic(
      primaryKey: ['id'],
      columns: ['id', 'value', 'other'],
    ),
    '$namespace.child': TableSchemaBasic(
      primaryKey: ['id'],
      columns: ['id', 'parent'],
    ),
    '$namespace.Items': TableSchemaBasic(
      primaryKey: ['value'],
      columns: ['value', 'other'],
    ),
  };
}

Future<Row> loadSatelliteMetaTable(
  DatabaseAdapter db,
  String namespace, {
  String metaTableName = '_electric_meta',
}) async {
  final rows = await db.query(
    Statement(
      'SELECT key, value FROM "$namespace"."$metaTableName"',
    ),
  );
  final entries = rows
      .map((x) => MapEntry<String, Object?>(x['key']! as String, x['value']));

  return Map.fromEntries(entries);
}

// This function should be only used to represent incoming transaction, not local
// transactions, as we treat cleatTags differently for incoming transactions.
OplogEntry generateLocalOplogEntry(
  TableInfo info,
  String namespace,
  String tablename,
  OpType optype,
  int timestamp,
  String? clearTags, {
  Row newValues = const {},
  Row oldValues = const {},
}) {
  final schema = info['$namespace.$tablename'];
  if (schema == null) {
    throw Exception('Schema is undefined');
  }

  final newRow = generateFrom(schema, newValues);

  GenerateFromResult oldRow = GenerateFromResult();
  if (optype == OpType.update || optype == OpType.delete) {
    oldRow = generateFrom(schema, oldValues);
  }
  String? tags = clearTags;
  if (optype == OpType.delete && clearTags == null) {
    tags = shadowTagsDefault;
  }
  if (optype != OpType.delete && clearTags == null) {
    tags = encodeTags([
      generateTag('remote', DateTime.fromMillisecondsSinceEpoch(timestamp)),
    ]);
  }

  final result = OplogEntry(
    namespace: namespace,
    tablename: tablename,
    optype: optype,
    rowid: timestamp,
    newRow: newRow.columns == null ? null : json.encode(newRow.columns),
    oldRow: oldRow.columns == null ? null : json.encode(oldRow.columns),
    primaryKey:
        json.encode({...oldRow.primaryKey ?? {}, ...newRow.primaryKey ?? {}}),
    timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp).toISOStringUTC(),
    clearTags: tags!,
  );

  return result;
}

OplogEntry generateRemoteOplogEntry(
  TableInfo info,
  String namespace,
  String tablename,
  OpType optype,
  int timestamp,
  String incomingTags, {
  Row newValues = const {},
  Row oldValues = const {},
}) {
  final schema = info['$namespace.$tablename'];
  if (schema == null) {
    throw Exception('Schema is undefined');
  }

  final newRow = generateFrom(schema, newValues);

  GenerateFromResult oldRow = GenerateFromResult();
  if (optype == OpType.update || optype == OpType.delete) {
    oldRow = generateFrom(schema, oldValues);
  }

  final result = OplogEntry(
    namespace: namespace,
    tablename: tablename,
    optype: optype,
    rowid: timestamp,
    newRow: newRow.columns == null ? null : json.encode(newRow.columns),
    oldRow: oldRow.columns == null ? null : json.encode(oldRow.columns),
    primaryKey:
        json.encode({...oldRow.primaryKey ?? {}, ...newRow.primaryKey ?? {}}),
    timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp).toISOStringUTC(),
    clearTags: incomingTags,
  );

  return result;
}

GenerateFromResult generateFrom(TableSchemaBasic schema, Row values) {
  final columns = schema.columns.fold<Row>({}, (acc, column) {
    if (values.containsKey(column)) {
      acc[column] = values[column];
    }

    return acc;
  });

  final primaryKey = schema.primaryKey.fold<Row>({}, (acc, column) {
    if (values[column] != null) {
      acc[column] = values[column];
    }

    return acc;
  });

  return GenerateFromResult(columns: columns, primaryKey: primaryKey);
}

class GenerateFromResult {
  final Row? columns;
  final Row? primaryKey;

  GenerateFromResult({this.columns, this.primaryKey});
}

String genEncodedTags(
  String origin,
  List<DateTime> dates,
) {
  final tags = dates.map((date) {
    return generateTag(origin, date);
  }).toList();
  return encodeTags(tags);
}

typedef GetMatchingShadowEntries = Future<List<ShadowEntry>> Function(
  DatabaseAdapter adapter, {
  OplogEntry? oplog,
  String namespace,
  String? shadowTable,
});

/// List all shadow entries, or get just one if an `oplog` parameter is provided
Future<List<ShadowEntry>> getMatchingShadowEntries(
  DatabaseAdapter adapter, {
  OplogEntry? oplog,
  QueryBuilder builder = kSqliteQueryBuilder,
  String? namespace,
  String? shadowTable,
}) async {
  namespace ??= builder.defaultNamespace;
  shadowTable ??= '"$namespace"._electric_shadow';

  final Statement query;
  String selectTags =
      'SELECT namespace, tablename, "primaryKey", tags FROM $shadowTable';
  if (oplog != null) {
    selectTags = '''
$selectTags WHERE
namespace = ${builder.makePositionalParam(1)} AND
tablename = ${builder.makePositionalParam(2)} AND
"primaryKey" = ${builder.makePositionalParam(3)}
''';
    final args = <Object?>[
      oplog.namespace,
      oplog.tablename,
      getShadowPrimaryKey(oplog),
    ];
    query = Statement(selectTags, args);
  } else {
    query = Statement(selectTags);
  }

  final rows = await adapter.query(query);

  return rows.map((e) {
    return ShadowEntry(
      namespace: e['namespace']! as String,
      tablename: e['tablename']! as String,
      primaryKey: e['primaryKey']! as String,
      tags: e['tags']! as String,
    );
  }).toList();
}

Future<List<ShadowEntry>> getSQLiteMatchingShadowEntries(
  DatabaseAdapter adapter, {
  OplogEntry? oplog,
  String namespace = 'main',
  String? shadowTable,
}) async {
  return getMatchingShadowEntries(
    adapter,
    oplog: oplog,
    builder: kSqliteQueryBuilder,
    namespace: namespace,
    shadowTable: shadowTable,
  );
}

Future<List<ShadowEntry>> getPgMatchingShadowEntries(
  DatabaseAdapter adapter, {
  OplogEntry? oplog,
  String namespace = 'public',
  String? shadowTable,
}) async {
  return getMatchingShadowEntries(
    adapter,
    oplog: oplog,
    builder: kPostgresQueryBuilder,
    namespace: namespace,
    shadowTable: shadowTable,
  );
}
