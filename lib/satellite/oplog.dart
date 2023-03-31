import 'dart:convert';

import 'package:electric_client/util/types.dart';

enum OpType {
  delete,
  insert,
  update,
  upsert,
}

class OplogEntry {
  final String namespace;
  final String tablename;
  final String primaryKey;
  final int rowid;
  final OpType optype;
  final String timestamp; // ISO string
  String? newRow;
  String? oldRow;

  OplogEntry({
    required this.namespace,
    required this.tablename,
    required this.primaryKey,
    required this.rowid,
    required this.optype,
    required this.timestamp,
    this.newRow,
    this.oldRow,
  });

  @override
  String toString() {
    return "$optype $namespace.$tablename $primaryKey - $newRow";
  }
}

OpType changeTypeToOpType(ChangeType opTypeStr) {
  switch (opTypeStr) {
    case ChangeType.insert:
      return OpType.insert;
    case ChangeType.update:
      return OpType.update;
    case ChangeType.delete:
      return OpType.delete;
  }
}

List<OplogEntry> fromTransaction(
  Transaction transaction,
  RelationsCache relations,
) {
  return transaction.changes.map((t) {
    final columnValues = t.record ?? t.oldRecord;
    final pk = json.encode(
      Map.fromEntries(
        relations[t.relation.table]
                ?.columns
                .where((c) => c.primaryKey ?? false)
                .map((col) => MapEntry(col.name, columnValues![col.name]))
                .toList() ??
            [],
      ),
    );

    return OplogEntry(
      namespace: "main", // TODO: how?
      tablename: t.relation.table,
      primaryKey: pk,
      rowid: -1, // Not required
      optype: changeTypeToOpType(t.type),
      timestamp: DateTime.fromMillisecondsSinceEpoch(transaction.commitTimestamp).toIso8601String(), //TODO: Revisar
      newRow: json.encode(t.record),
      oldRow: json.encode(t.oldRecord),
    );
  }).toList();
}
