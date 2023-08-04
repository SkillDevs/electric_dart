import 'dart:convert';

import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/types.dart';

typedef TableInfo = Map<String, TableSchema>;

class TableSchema {
  final List<String> primaryKey;
  final List<String> columns;

  TableSchema({required this.primaryKey, required this.columns});
}

TableInfo initTableInfo() {
  return {
    'main.parent': TableSchema(
      primaryKey: ['id'],
      columns: ['id', 'value', 'other'],
    ),
    'main.child': TableSchema(
      primaryKey: ['id'],
      columns: ['id', 'parent'],
    ),
    'main.Items': TableSchema(
      primaryKey: ['value'],
      columns: ['value', 'other'],
    ),
  };
}

Future<Row> loadSatelliteMetaTable(
  DatabaseAdapter db, {
  String metaTableName = '_electric_meta',
}) async {
  final rows = await db.query(
    Statement(
      'SELECT key, value FROM $metaTableName',
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
  final schema = info[namespace + '.' + tablename];
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
      generateTag('remote', DateTime.fromMillisecondsSinceEpoch(timestamp))
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

GenerateFromResult generateFrom(TableSchema schema, Row values) {
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

/// List all shadow entires, or get just one if an `oplog` parameter is provided
Future<List<ShadowEntry>> getMatchingShadowEntries(
  DatabaseAdapter adapter, {
  OplogEntry? oplog,
  String shadowTable = 'main._electric_shadow',
}) async {
  final Statement query;
  String selectTags = 'SELECT * FROM $shadowTable';
  if (oplog != null) {
    selectTags = selectTags +
        '''
 WHERE
namespace = ? AND
tablename = ? AND
primaryKey = ?
''';
    final args = <Object?>[
      oplog.namespace,
      oplog.tablename,
      getShadowPrimaryKey(oplog)
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
