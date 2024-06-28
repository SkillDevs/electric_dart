import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/client/validation/validation.dart';
import 'package:electricsql/util.dart';

abstract class IReplicationTransformManager {
  void setTableTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<DbRecord> transform,
  );

  void clearTableTransform(QualifiedTablename tableName);

  DbRecord transformTableRecord<D>(
    DbRecord record,
    D Function(D row) transformRow,
    Fields fields,
    List<String> immutableFields, {
    required void Function(D)? validateFun,
    required Map<String, Object?> Function(D) toRecord,
    required D Function(Map<String, Object?>) fromRecord,
  });
}

class ReplicationTransformManager implements IReplicationTransformManager {
  final Satellite satellite;

  ReplicationTransformManager(this.satellite);

  @override
  void setTableTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<DbRecord> transform,
  ) {
    satellite.setReplicationTransform(tableName, transform);
  }

  @override
  void clearTableTransform(QualifiedTablename tableName) {
    satellite.clearReplicationTransform(tableName);
  }

  @override
  DbRecord transformTableRecord<D>(
    DbRecord record,
    D Function(D row) transformRow,
    Fields fields,
    List<String> immutableFields, {
    required void Function(D)? validateFun,
    required Map<String, Object?> Function(D) toRecord,
    required D Function(Map<String, Object?>) fromRecord,
  }) {
    return transformTableRecordGeneric<DbRecord>(
      record,
      (r) => toRecord(transformRow(fromRecord(r))),
      fields,
      immutableFields,
      validateFun:
          validateFun == null ? null : (d) => validateFun(fromRecord(d)),
      toRecord: (d) => d,
    );
  }
}

/// Transform a raw record with the given typed row transformation {@link transformRow}
/// by applying appropriate parsing and validation, including forbidding
/// changes to specified {@link immutableFields}
///
/// @param transformRow transformation of record of type {@link T}
/// @param fields fields to specify the transformation from raw record to record of type {@link T}
/// @param schema schema to parse/validate raw record to record of type {@link T}
/// @param immutableFields - fields that cannot be modified by {@link transformRow}
/// @return the transformed raw record
D transformTableRecordGeneric<D>(
  D record,
  D Function(D) transformRow,
  Fields fields,
  List<String> immutableFields, {
  required void Function(D)? validateFun,
  required Map<String, Object?> Function(D) toRecord,
}) {
  // apply specified transformation
  final transformedParsedRow = transformRow(record);

  // validate transformed row and convert back to raw record
  // schema is only provided when using the DAL
  // if validateFun is not provided, we skip validation
  validateFun?.call(transformedParsedRow);

  final originalCols = toRecord(record);
  final transformedCols = toRecord(transformedParsedRow);

  for (final newKey in transformedCols.keys) {
    if (!originalCols.containsKey(newKey)) {
      throw Exception('Unrecognized column: $newKey');
    }
  }

  // print('originalCols: $originalCols');
  // print('transformedCols: $transformedCols');

  // check if any of the immutable fields were modified
  validateRecordTransformation(
    originalCols,
    transformedCols,
    immutableFields,
  );

  return transformedParsedRow;
}

void setReplicationTransform<T>({
  required DBSchema dbDescription,
  required IReplicationTransformManager replicationTransformManager,
  required QualifiedTablename qualifiedTableName,
  required T Function(T row) transformInbound,
  required T Function(T row) transformOutbound,
  required void Function(T)? validateFun,
  required Map<String, Object?> Function(T) toRecord,
  required T Function(Map<String, Object?>) fromRecord,
}) {
  final tableName = qualifiedTableName.tablename;

  if (!dbDescription.hasTable(tableName)) {
    throw Exception(
      "Cannot set replication transform for table '$tableName'. Table does not exist in the database schema.",
    );
  }

  final fields = dbDescription.getFields(tableName);

  // forbid transforming relation keys to avoid breaking
  // referential integrity

  // the column could be the FK column when it is an outgoing FK
  // or it could be a PK column when it is an incoming FK
  final fkCols = dbDescription
      .getOutgoingRelations(tableName)
      .map((r) => r.fromField)
      .toList();

  // Incoming relations don't have the `fromField` and `toField` filled in
  // so we need to fetch the `toField` from the opposite relation
  // which is effectively a column in this table to which the FK points
  final pkCols = dbDescription
      .getIncomingRelations(tableName)
      .map((r) => r.getOppositeRelation(dbDescription).toField);

  // Merge all columns that are part of a FK relation.
  // Remove duplicate columns in case a column has both an outgoing FK and an incoming FK.
  final immutableFields = <String>{...fkCols, ...pkCols}.toList();

  replicationTransformManager.setTableTransform(
    qualifiedTableName,
    ReplicatedRowTransformer(
      transformInbound: (DbRecord record) {
        return replicationTransformManager.transformTableRecord<T>(
          record,
          transformInbound,
          fields,
          immutableFields,
          validateFun: validateFun,
          toRecord: toRecord,
          fromRecord: fromRecord,
        );
      },
      transformOutbound: (DbRecord record) {
        return replicationTransformManager.transformTableRecord<T>(
          record,
          transformOutbound,
          fields,
          immutableFields,
          validateFun: validateFun,
          toRecord: toRecord,
          fromRecord: fromRecord,
        );
      },
    ),
  );
}
