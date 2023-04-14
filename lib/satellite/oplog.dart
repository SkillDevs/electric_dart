import 'dart:convert';

import 'package:electric_client/util/common.dart';
import 'package:electric_client/util/sets.dart';
import 'package:electric_client/util/tablename.dart';
import 'package:electric_client/util/types.dart';
import 'package:fixnum/fixnum.dart';

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

class OplogEntryChanges {
  final String namespace;
  final String tablename;
  final Map<String, Object> primaryKeyCols;
  ChangesOpType optype;
  final OplogColumnChanges changes;
  Tag? tag;
  List<Tag> clearTags;

  OplogEntryChanges({
    required this.namespace,
    required this.tablename,
    required this.primaryKeyCols,
    required this.optype,
    required this.changes,
    required this.tag,
    required this.clearTags,
  });
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

const shadowTagsDefault = '[]';

OpType opTypeStrToOpType(String str) {
  switch (str.toLowerCase()) {
    case "delete":
      return OpType.delete;
    case "update":
      return OpType.update;
    case "upsert":
      return OpType.upsert;
    case "insert":
      return OpType.insert;
  }

  assert(false, "OpType $str not handled");
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
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(transaction.commitTimestamp.toInt()).toIso8601String(), //TODO: Revisar
      newRow: t.record == null ? null : json.encode(t.record),
      oldRow: t.oldRecord == null ? null : json.encode(t.oldRecord),
      clearTags: encodeTags(t.tags),
    );
  }).toList();
}

List<Transaction> toTransactions(List<OplogEntry> opLogEntries, RelationsCache relations) {
  if (opLogEntries.isEmpty) {
    return [];
  }

  Int64 to_commit_timestamp(String timestamp) {
    // TODO: Uint64 dart protobuf doesn't have a explicit type for this
    return Int64(DateTime.parse(timestamp).millisecondsSinceEpoch);
  }

  Change opLogEntryToChange(OplogEntry entry) {
    Map<String, Object?>? record, oldRecord;
    if (entry.newRow != null) {
      record = json.decode(entry.newRow!);
    }

    if (entry.oldRow != null) {
      oldRecord = json.decode(entry.oldRow!);
    }

    // FIXME: We should not loose UPDATE information here, as otherwise
    // it will be identical to setting all values in a transaction, instead
    // of updating values (different CR outcome)
    return Change(
      type: entry.optype == OpType.delete ? ChangeType.delete : ChangeType.insert,
      relation: relations[entry.tablename]!,
      record: record,
      oldRecord: oldRecord,
      tags: decodeTags(entry.clearTags),
    );
  }

  final Transaction init = Transaction(
    commitTimestamp: to_commit_timestamp(opLogEntries[0].timestamp),
    lsn: numberToBytes(opLogEntries[0].rowid),
    changes: [],
  );

  return opLogEntries.fold(
    [init],
    (acc, txn) {
      var currTxn = acc[acc.length - 1];

      final nextTs = to_commit_timestamp(txn.timestamp);
      if (nextTs != currTxn.commitTimestamp) {
        final nextTxn = Transaction(
          commitTimestamp: to_commit_timestamp(txn.timestamp),
          lsn: numberToBytes(txn.rowid),
          changes: [],
        );
        acc.add(nextTxn);
        currTxn = nextTxn;
      }

      final change = opLogEntryToChange(txn);
      currTxn.changes.add(change);
      currTxn.lsn = numberToBytes(txn.rowid);
      return acc;
    },
  );
}

ShadowEntry newShadowEntry(OplogEntry oplogEntry) {
  return ShadowEntry(
    namespace: oplogEntry.namespace,
    tablename: oplogEntry.tablename,
    primaryKey: primaryKeyToStr((json.decode(oplogEntry.primaryKey) as Map<String, dynamic>).cast<String, Object>()),
    tags: shadowTagsDefault,
  );
}

// Convert a list of `OplogEntry`s into a nested `OplogTableChanges` map of
// `{tableName: {primaryKey: entryChanges}}` where the entryChanges has the
// most recent `optype` and column `value`` from all of the operations.
// Multiple OplogEntries that point to the same row will be merged to a
// single OpLogEntryChanges object.
OplogTableChanges localOperationsToTableChanges(
  List<OplogEntry> operations,
  Tag Function(DateTime timestamp) genTag,
) {
  final OplogTableChanges initialValue = {};

  return operations.fold(initialValue, (acc, entry) {
    final entryChanges = localEntryToChanges(entry, genTag(DateTime.parse(entry.timestamp)));

    // Sort for deterministic key generation.
    final primaryKeyStr = primaryKeyToStr(entryChanges.primaryKeyCols);
    final qualifiedTablename = QualifiedTablename(entryChanges.namespace, entryChanges.tablename);
    final tablenameStr = qualifiedTablename.toString();

    if (acc[tablenameStr] == null) {
      acc[tablenameStr] = {};
    }

    if (acc[tablenameStr]![primaryKeyStr] == null) {
      acc[tablenameStr]![primaryKeyStr] = OplogTableChange(timestamp: entry.timestamp, oplogEntryChanges: entryChanges);
    } else {
      final oplogTableChange = acc[tablenameStr]![primaryKeyStr]!;
      final timestamp = oplogTableChange.timestamp;
      final OplogEntryChanges existing = oplogTableChange.oplogEntryChanges;

      existing.optype = entryChanges.optype;
      for (final entry in entryChanges.changes.entries) {
        final key = entry.key;
        final value = entry.value;
        existing.changes[key] = value;
      }
      if (entryChanges.optype == OpType.delete) {
        existing.tag = null;
      } else {
        existing.tag = genTag(DateTime.parse(entry.timestamp));
      }

      if (timestamp == entry.timestamp) {
        // within the same transaction overwirte
        existing.clearTags = entryChanges.clearTags;
      } else {
        existing.clearTags = union(entryChanges.clearTags, existing.clearTags);
      }
    }

    return acc;
  });
}

ShadowTableChanges remoteOperationsToTableChanges(List<OplogEntry> operations) {
  final ShadowTableChanges initialValue = {};

  return operations.fold<ShadowTableChanges>(initialValue, (acc, entry) {
    final entryChanges = remoteEntryToChanges(entry);

    // Sort for deterministic key generation.
    final primaryKeyStr = primaryKeyToStr(entryChanges.primaryKeyCols);
    final qualifiedTablename = QualifiedTablename(entryChanges.namespace, entryChanges.tablename);
    final tablenameStr = qualifiedTablename.toString();

    if (acc[tablenameStr] == null) {
      acc[tablenameStr] = {};
    }
    if (acc[tablenameStr]![primaryKeyStr] == null) {
      acc[tablenameStr]![primaryKeyStr] = entryChanges;
    } else {
      final ShadowEntryChanges existing = acc[tablenameStr]![primaryKeyStr]!;
      existing.optype = entryChanges.optype;
      for (final entry in entryChanges.changes.entries) {
        existing.changes[entry.key] = entry.value;
      }
    }

    return acc;
  });
}

class OplogTableChange {
  final Timestamp timestamp;
  final OplogEntryChanges oplogEntryChanges;

  OplogTableChange({
    required this.timestamp,
    required this.oplogEntryChanges,
  });
}

class OplogColumnChange {
  final SqlValue value;
  final int timestamp;

  OplogColumnChange(this.value, this.timestamp);
}

typedef OplogColumnChanges = Map<String, OplogColumnChange>;

// First key qualifiedTablenameStr
// Second key primaryKey
typedef ShadowTableChanges = Map<String, Map<String, ShadowEntryChanges>>;
typedef OplogTableChanges = Map<String, Map<String, OplogTableChange>>;

class ShadowEntry {
  final String namespace;
  final String tablename;
  final String primaryKey;
  String tags;

  ShadowEntry({
    required this.namespace,
    required this.tablename,
    required this.primaryKey,
    required this.tags,
  }); // json object
}

// Convert an `OplogEntry` to an `OplogEntryChanges` structure,
// parsing out the changed columns from the oldRow and the newRow.
OplogEntryChanges localEntryToChanges(OplogEntry entry, Tag tag) {
  final OplogEntryChanges result = OplogEntryChanges(
    namespace: entry.namespace,
    tablename: entry.tablename,
    primaryKeyCols: (json.decode(entry.primaryKey) as Map<String, dynamic>).cast<String, Object>(),
    optype: entry.optype == OpType.delete ? ChangesOpType.delete : ChangesOpType.upsert,
    changes: {},
    tag: entry.optype == OpType.delete ? null : tag,
    clearTags: (json.decode(entry.clearTags) as List<dynamic>).cast<String>(),
  );

  final Row oldRow = entry.oldRow != null ? json.decode(entry.oldRow!) : {};
  final Row newRow = entry.newRow != null ? json.decode(entry.newRow!) : {};

  final timestamp = DateTime.parse(entry.timestamp).millisecondsSinceEpoch;

  for (final entry in newRow.entries) {
    final key = entry.key;
    final value = entry.value;
    if (oldRow[key] == value) {
      result.changes[key] = OplogColumnChange(value, timestamp);
    }
  }
  return result;
}

// Convert an `OplogEntry` to a `ShadowEntryChanges` structure,
// parsing out the changed columns from the oldRow and the newRow.
ShadowEntryChanges remoteEntryToChanges(OplogEntry entry) {
  final result = ShadowEntryChanges(
    namespace: entry.namespace,
    tablename: entry.tablename,
    primaryKeyCols: (json.decode(entry.primaryKey) as Map<String, dynamic>).cast<String, Object>(),
    optype: entry.optype == OpType.delete ? ChangesOpType.delete : ChangesOpType.upsert,
    changes: {},
    tags: decodeTags(entry.clearTags),
  );

  final Row oldRow = entry.oldRow != null ? json.decode(entry.oldRow!) : {};
  final Row newRow = entry.newRow != null ? json.decode(entry.newRow!) : {};

  final timestamp = DateTime.parse(entry.timestamp).millisecondsSinceEpoch;

  for (final entry in newRow.entries) {
    if (oldRow[entry.key] != entry.value) {
      result.changes[entry.key] = OplogColumnChange(entry.value, timestamp);
    }
  }

  return result;
}

class ShadowEntryChanges {
  final String namespace;
  final String tablename;
  final Map<String, Object> primaryKeyCols;
  ChangesOpType optype;
  OplogColumnChanges changes;
  List<Tag> tags;

  ShadowEntryChanges({
    required this.namespace,
    required this.tablename,
    required this.primaryKeyCols,
    required this.optype,
    required this.changes,
    required this.tags,
  });
}

String primaryKeyToStr(Map<String, Object> primaryKeyJson) {
  final sortedValues = primaryKeyJson.values.toList()..sort();
  return sortedValues.join("_");
}

ShadowKey getShadowPrimaryKey(
  Object oplogEntry,
) {
  if (oplogEntry is OplogEntry) {
    return primaryKeyToStr((json.decode(oplogEntry.primaryKey) as Map<String, dynamic>).cast<String, Object>());
  } else if (oplogEntry is OplogEntryChanges) {
    return primaryKeyToStr(oplogEntry.primaryKeyCols);
  } else if (oplogEntry is ShadowEntryChanges) {
    return primaryKeyToStr(oplogEntry.primaryKeyCols);
  } else {
    throw StateError("Unknown class");
  }
}

Tag generateTag(String instanceId, DateTime timestamp) {
  final milliseconds = timestamp.millisecondsSinceEpoch;
  return '$instanceId@$milliseconds';
}

String encodeTags(List<Tag> tags) {
  return json.encode(tags);
}

List<Tag> decodeTags(String tags) {
  return (json.decode(tags) as List<dynamic>).cast<Tag>();
}
