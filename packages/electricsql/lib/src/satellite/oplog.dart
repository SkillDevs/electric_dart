import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/converters/helpers.dart';
import 'package:electricsql/src/util/sets.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:equatable/equatable.dart';
import 'package:fixnum/fixnum.dart';

// format: UUID@timestamp_in_milliseconds
typedef Timestamp = String;
typedef Tag = String;

typedef ShadowKey = String;

enum OpType {
  delete,
  insert,
  update,
  compensation,
  gone,
}

enum ChangesOpType {
  delete,
  upsert,
  gone,
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

class OplogEntry with EquatableMixin {
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
    return '$optype $namespace.$tablename $primaryKey - $newRow';
  }

  @override
  List<Object?> get props => [
        namespace,
        tablename,
        primaryKey,
        rowid,
        optype,
        timestamp,
        newRow,
        oldRow,
        clearTags,
      ];
}

OpType changeTypeToOpType(DataChangeType opType) {
  switch (opType) {
    case DataChangeType.insert:
      return OpType.insert;
    case DataChangeType.update:
      return OpType.update;
    case DataChangeType.delete:
      return OpType.delete;
    case DataChangeType.gone:
      return OpType.gone;
    default:
      throw Exception('Unexpected opType: $opType');
  }
}

DataChangeType opTypeToChangeType(OpType opType) {
  switch (opType) {
    case OpType.delete:
      return DataChangeType.delete;
    case OpType.insert:
      return DataChangeType.insert;
    case OpType.update:
      return DataChangeType.update;
    case OpType.gone:
      return DataChangeType.gone;
    case OpType.compensation:
      return DataChangeType.compensation;
  }
}

const shadowTagsDefault = '[]';

OpType opTypeStrToOpType(String str) {
  switch (str.toLowerCase()) {
    case 'delete':
      return OpType.delete;
    case 'update':
      return OpType.update;
    case 'insert':
      return OpType.insert;
    case 'compensation':
      return OpType.compensation;
  }

  throw Exception('Unknown opType: $str');
}

List<OplogEntry> fromTransaction(
  DataTransaction transaction,
  RelationsCache relations,
) {
  return transaction.changes.map((t) {
    final columnValues = t.record ?? t.oldRecord!;
    final pk = primaryKeyToStr(
      Map.fromEntries(
        relations[t.relation.table]!
            .columns
            .where((c) => c.primaryKey != null && c.primaryKey != 0)
            .map((col) => MapEntry(col.name, columnValues[col.name]!)),
      ),
    );

    return OplogEntry(
      namespace: 'main', // TODO: how?
      tablename: t.relation.table,
      primaryKey: pk,
      rowid: -1, // Not required
      optype: changeTypeToOpType(t.type),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        transaction.commitTimestamp.toInt(),
      ).toISOStringUTC(), // TODO: check precision
      newRow: t.record == null ? null : serialiseRow(t.record!),
      oldRow: t.oldRecord == null ? null : serialiseRow(t.oldRecord!),
      clearTags: encodeTags(t.tags),
    );
  }).toList();
}

List<DataTransaction> toTransactions(
  List<OplogEntry> opLogEntries,
  RelationsCache relations,
) {
  if (opLogEntries.isEmpty) {
    return [];
  }

  Int64 toCommitTimestamp(String timestamp) {
    return Int64(DateTime.parse(timestamp).millisecondsSinceEpoch);
  }

  final init = DataTransaction(
    commitTimestamp: toCommitTimestamp(opLogEntries[0].timestamp),
    lsn: numberToBytes(opLogEntries[0].rowid),
    changes: [],
  );

  return opLogEntries.fold(
    [init],
    (acc, txn) {
      var currTxn = acc[acc.length - 1];

      final nextTs = toCommitTimestamp(txn.timestamp);
      if (nextTs != currTxn.commitTimestamp) {
        final nextTxn = DataTransaction(
          commitTimestamp: toCommitTimestamp(txn.timestamp),
          lsn: numberToBytes(txn.rowid),
          changes: [],
        );
        acc.add(nextTxn);
        currTxn = nextTxn;
      }

      final change = opLogEntryToChange(txn, relations);
      currTxn.changes.add(change);
      currTxn.lsn = numberToBytes(txn.rowid);
      return acc;
    },
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
  RelationsCache relations,
) {
  final OplogTableChanges initialValue = {};

  return operations.fold(initialValue, (acc, entry) {
    final entryChanges = localEntryToChanges(
      entry,
      genTag(DateTime.parse(entry.timestamp)),
      relations,
    );

    // Sort for deterministic key generation.
    final primaryKeyStr = primaryKeyToStr(entryChanges.primaryKeyCols);
    final qualifiedTablename =
        QualifiedTablename(entryChanges.namespace, entryChanges.tablename);
    final tablenameStr = qualifiedTablename.toString();

    if (acc[tablenameStr] == null) {
      acc[tablenameStr] = {};
    }

    if (acc[tablenameStr]![primaryKeyStr] == null) {
      acc[tablenameStr]![primaryKeyStr] = OplogTableChange(
        timestamp: entry.timestamp,
        oplogEntryChanges: entryChanges,
      );
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
      if (entryChanges.optype == ChangesOpType.delete) {
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

PendingChanges remoteOperationsToTableChanges(
  List<OplogEntry> operations,
  RelationsCache relations,
) {
  final PendingChanges initialValue = {};

  return operations.fold<PendingChanges>(initialValue, (acc, entry) {
    final entryChanges = remoteEntryToChanges(entry, relations);

    // Sort for deterministic key generation.
    final primaryKeyStr = primaryKeyToStr(entryChanges.primaryKeyCols);
    final qualifiedTablename =
        QualifiedTablename(entryChanges.namespace, entryChanges.tablename);
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
        existing.fullRow[entry.key] = entry.value.value;
      }
    }

    return acc;
  });
}

/// Serialises a row that is represented by a record.
/// `NaN`, `+Inf`, and `-Inf` are transformed to their string equivalent.
/// Bytestrings are encoded as hex strings
/// @param record The row to serialise.
String serialiseRow(Row row) {
  final convertedToSpec = row.map((key, value) {
    if (value is double) {
      if (value.isNaN) {
        return MapEntry(key, 'NaN');
      } else if (value.isInfinite) {
        return MapEntry(key, value.isNegative ? '-Inf' : 'Inf');
      }
    } else if (value is BigInt) {
      return MapEntry(key, value.toString());
    }

    if (value is List<int>) {
      return MapEntry(key, blobToHexString(value));
    }

    return MapEntry(key, value);
  });

  return json.encode(convertedToSpec);
}

/// Deserialises a row back into a record.
/// `"NaN"`, `"+Inf"`, and `"-Inf"` are transformed back into their numeric equivalent
/// if the column type is a float.
/// Hex encoded bytestrings are transformed back to `Uint8Array` instances
/// @param str The row to deserialise.
/// @param rel The relation for the table to which this row belongs.
Row deserialiseRow(String str, Relation rel) {
  final parsed = json.decode(str) as Map<String, Object?>;

  return parsed.map((key, value) {
    if (value == null) {
      return MapEntry(key, null);
    }

    final columnType = rel.columns
        .firstWhereOrNull((c) => c.name == key)
        ?.type
        .toUpperCase()
        .replaceAll(' ', '');
    if ((columnType == 'FLOAT4' ||
            columnType == 'FLOAT8' ||
            columnType == 'REAL') &&
        value is String) {
      if (value == 'NaN') {
        return MapEntry(key, double.nan);
      } else if (value == 'Inf') {
        return MapEntry(key, double.infinity);
      } else if (value == '-Inf') {
        return MapEntry(key, double.negativeInfinity);
      } else {
        return MapEntry(key, double.parse(value));
      }
    }

    if (columnType == 'INT8' || columnType == 'BIGINT') {
      return MapEntry(key, BigInt.parse(value.toString()));
    }
    if ((columnType == 'BYTEA' || columnType == 'BLOB') && value is String) {
      return MapEntry(key, hexStringToBlob(value));
    }

    return MapEntry(key, value);
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

class OplogColumnChange with EquatableMixin {
  final SqlValue value;
  final int timestamp;

  OplogColumnChange(this.value, this.timestamp);

  @override
  List<Object?> get props => [value, timestamp];
}

typedef OplogColumnChanges = Map<String, OplogColumnChange>;

// First key qualifiedTablenameStr
// Second key primaryKey
typedef PendingChanges = Map<String, Map<String, ShadowEntryChanges>>;
typedef OplogTableChanges = Map<String, Map<String, OplogTableChange>>;

class ShadowEntry with EquatableMixin {
  final String namespace;
  final String tablename;
  final String primaryKey;
  String tags;

  ShadowEntry({
    required this.namespace,
    required this.tablename,
    required this.primaryKey,
    required this.tags,
  });

  @override
  List<Object?> get props =>
      [namespace, tablename, primaryKey, tags]; // json object
}

// Convert an `OplogEntry` to an `OplogEntryChanges` structure,
// parsing out the changed columns from the oldRow and the newRow.
OplogEntryChanges localEntryToChanges(
  OplogEntry entry,
  Tag tag,
  RelationsCache relations,
) {
  final relation = relations[entry.tablename]!;

  final OplogEntryChanges result = OplogEntryChanges(
    namespace: entry.namespace,
    tablename: entry.tablename,
    primaryKeyCols:
        deserialiseRow(entry.primaryKey, relation).cast<String, Object>(),
    optype: entry.optype == OpType.delete
        ? ChangesOpType.delete
        : ChangesOpType.upsert,
    changes: {},
    tag: entry.optype == OpType.delete ? null : tag,
    clearTags: (json.decode(entry.clearTags) as List<dynamic>).cast<String>(),
  );

  final Row oldRow =
      entry.oldRow != null ? deserialiseRow(entry.oldRow!, relation) : {};
  final Row newRow =
      entry.newRow != null ? deserialiseRow(entry.newRow!, relation) : {};

  final timestamp = DateTime.parse(entry.timestamp).millisecondsSinceEpoch;

  for (final entry in newRow.entries) {
    final key = entry.key;
    final value = entry.value;
    if (!oldRow.containsKey(key) || oldRow[key] != value) {
      result.changes[key] = OplogColumnChange(value, timestamp);
    }
  }
  return result;
}

// Convert an `OplogEntry` to a `ShadowEntryChanges` structure,
// parsing out the changed columns from the oldRow and the newRow.
ShadowEntryChanges remoteEntryToChanges(
  OplogEntry entry,
  RelationsCache relations,
) {
  final relation = relations[entry.tablename]!;
  final Row oldRow =
      entry.oldRow != null ? deserialiseRow(entry.oldRow!, relation) : {};
  final Row newRow =
      entry.newRow != null ? deserialiseRow(entry.newRow!, relation) : {};

  final result = ShadowEntryChanges(
    namespace: entry.namespace,
    tablename: entry.tablename,
    primaryKeyCols:
        deserialiseRow(entry.primaryKey, relation).cast<String, Object>(),
    optype: optypeToShadow(entry.optype),
    changes: {},
    // if it is a delete, then `newRow` is empty so the full row is the old row
    fullRow: entry.optype == OpType.delete ? oldRow : newRow,
    tags: decodeTags(entry.clearTags),
  );

  final timestamp = DateTime.parse(entry.timestamp).millisecondsSinceEpoch;

  for (final entry in newRow.entries) {
    if (!oldRow.containsKey(entry.key) || oldRow[entry.key] != entry.value) {
      result.changes[entry.key] = OplogColumnChange(entry.value, timestamp);
    }
  }

  return result;
}

ChangesOpType optypeToShadow(OpType optype) {
  switch (optype) {
    case OpType.delete:
      return ChangesOpType.delete;
    case OpType.gone:
      return ChangesOpType.gone;
    case OpType.insert:
    case OpType.update:
      return ChangesOpType.upsert;
    default:
      throw Exception('Unexpected optype: $optype');
  }
}

class ShadowEntryChanges with EquatableMixin {
  final String namespace;
  final String tablename;
  final Map<String, Object> primaryKeyCols;
  ChangesOpType optype;
  OplogColumnChanges changes;
  Row fullRow;
  List<Tag> tags;

  ShadowEntryChanges({
    required this.namespace,
    required this.tablename,
    required this.primaryKeyCols,
    required this.optype,
    required this.changes,
    required this.fullRow,
    required this.tags,
  });

  @override
  List<Object?> get props =>
      [namespace, tablename, primaryKeyCols, optype, changes, fullRow, tags];
}

/// Convert a primary key to a string the same way our triggers do when generating oplog entries.
///
/// Takes the object that contains the primary key and serializes it to JSON in a non-prettified
/// way with column sorting.
///
/// @param primaryKeyObj object representing all columns of a primary key
/// @returns a stringified JSON with stable sorting on column names
String primaryKeyToStr(Map<String, Object> primaryKeyObj) {
  // TODO: it probably makes more sense to sort the PK object by actual PK order
  final keys = primaryKeyObj.keys.toList()..sort();

  final sortedObj = <String, Object>{};
  for (final key in keys) {
    sortedObj[key] = primaryKeyObj[key]!;
  }

  return serialiseRow(sortedObj);
}

ShadowKey getShadowPrimaryKey(
  Object oplogEntry,
) {
  if (oplogEntry is OplogEntry) {
    return oplogEntry.primaryKey;
  } else if (oplogEntry is OplogEntryChanges) {
    return primaryKeyToStr(oplogEntry.primaryKeyCols);
  } else if (oplogEntry is ShadowEntryChanges) {
    return primaryKeyToStr(oplogEntry.primaryKeyCols);
  } else {
    throw StateError('Unknown class');
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

DataChange opLogEntryToChange(OplogEntry entry, RelationsCache relations) {
  final relation = relations[entry.tablename];

  if (relation == null) {
    throw Exception('Could not find relation for ${entry.tablename}');
  }

  Map<String, Object?>? record;
  Map<String, Object?>? oldRecord;
  if (entry.newRow != null) {
    record = deserialiseRow(entry.newRow!, relation);
  }

  if (entry.oldRow != null) {
    oldRecord = deserialiseRow(entry.oldRow!, relation);
  }

  return DataChange(
    type: opTypeToChangeType(entry.optype),
    relation: relation,
    record: record,
    oldRecord: oldRecord,
    tags: decodeTags(entry.clearTags),
  );
}
