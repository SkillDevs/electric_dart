import 'dart:convert';

import 'package:electric_client/satellite/oplog.dart';
import 'package:electric_client/satellite/oplog.dart';
import 'package:electric_client/util/types.dart';

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
    'main.items': TableSchema(
      primaryKey: ['value'],
      columns: ['value', 'other'],
    ),
  };
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
    newRow: json.encode(newRow.columns),
    oldRow: json.encode(oldRow.columns),
    primaryKey: json.encode({...oldRow.primaryKey ?? {}, ...newRow.primaryKey ?? {}}),
    timestamp: DateTime(timestamp).toIso8601String(),
    clearTags: incomingTags,
  );

  return result;
}

GenerateFromResult generateFrom(TableSchema schema, Row values) {
  final columns = schema.columns.fold<Row>({}, (acc, column) {
    if (values[column] != null) {
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
