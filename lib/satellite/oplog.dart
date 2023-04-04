import 'dart:convert';

import 'package:electric_client/util/types.dart';

// format: UUID@timestamp_in_milliseconds
typedef Timestamp = String;
typedef Tag = String;

typedef ShadowKey = String;

enum OpType {
  delete,
  insert,
  update,
  upsert,
}

enum ChangesOpType {
  delete,
  upsert,
}

class OplogEntry {
  final String namespace;
  final String tablename;
  final String primaryKey; // json object
  final int rowid;
  final OpType optype;
  final String timestamp; // ISO string
  String? newRow; // json object if present
  String? oldRow; // json object if present
  String clearTags; // json object if present

  OplogEntry({
    required this.namespace,
    required this.tablename,
    required this.primaryKey,
    required this.rowid,
    required this.optype,
    required this.timestamp,
    required this.clearTags,
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

OpType opTypeStrToOpType(String str) {
  switch (str) {
    case "delete":
      return OpType.delete;
    case "update":
      return OpType.delete;
    case "upsert":
      return OpType.upsert;
    case "insert":
      return OpType.insert;
  }

  assert(false, "OpType $str not hanlded");
  return OpType.insert;
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
      clearTags: json.encode(t.tags),
    );
  }).toList();
}

// // Convert a list of `OplogEntry`s into a nested `OplogTableChanges` map of
// // `{tableName: {primaryKey: entryChanges}}` where the entryChanges has the
// // most recent `optype` and column `value`` from all of the operations.
// // Multiple OplogEntries that point to the same row will be merged to a
// // single OpLogEntryChanges object.
// OplogTableChanges localOperationsToTableChanges = (
//   List<OplogEntry> operations,
//   Tag Function(DateTime timestamp) genTag,
// ) {
//   var initialValue: OplogTableChanges;

//   return operations.reduce((acc, entry) {
//     const entryChanges = localEntryToChanges(
//       entry,
//       genTag(new Date(entry.timestamp))
//     )

//     // Sort for deterministic key generation.
//     const primaryKeyStr = primaryKeyToStr(entryChanges.primaryKeyCols)
//     const qualifiedTablename = new QualifiedTablename(
//       entryChanges.namespace,
//       entryChanges.tablename
//     )
//     const tablenameStr = qualifiedTablename.toString()

//     if (acc[tablenameStr] === undefined) {
//       acc[tablenameStr] = {}
//     }

//     if (acc[tablenameStr][primaryKeyStr] === undefined) {
//       acc[tablenameStr][primaryKeyStr] = [entry.timestamp, entryChanges]
//     } else {
//       const [timestamp, existing] = acc[tablenameStr][primaryKeyStr]
//       existing.optype = entryChanges.optype
//       for (const [key, value] of Object.entries(entryChanges.changes)) {
//         existing.changes[key] = value
//       }
//       if (entryChanges.optype == 'DELETE') {
//         existing.tag = null
//       } else {
//         existing.tag = genTag(new Date(entry.timestamp))
//       }

//       if (timestamp == entry.timestamp) {
//         // within the same transaction overwirte
//         existing.clearTags = entryChanges.clearTags
//       } else {
//         existing.clearTags = union(entryChanges.clearTags, existing.clearTags)
//       }
//     }

//     return acc
//   }, initialValue)
// }

class OplogColumnChange {
  final SqlValue value;
  final int timestamp;

  OplogColumnChange(this.value, this.timestamp);
}

typedef OplogColumnChanges = Map<String, OplogColumnChange>;

class ShadowEntryChanges {
  final String namespace;
  final String tablename;
  final Map<String, Object> primaryKeyCols;
  final ChangesOpType optype;
  final OplogColumnChanges changes;
  final List<Tag> tags;

  ShadowEntryChanges({
    required this.namespace,
    required this.tablename,
    required this.primaryKeyCols,
    required this.optype,
    required this.changes,
    required this.tags,
  });
}
