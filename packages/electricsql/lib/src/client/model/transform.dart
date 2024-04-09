import 'package:drift/drift.dart';
import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/validation/validation.dart';
import 'package:electricsql/util.dart';

abstract class IReplicationTransformManager {
  void setTableTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<Record> transform,
  );

  void clearTableTransform(QualifiedTablename tableName);
}

class ReplicationTransformManager implements IReplicationTransformManager {
  final Satellite satellite;

  ReplicationTransformManager(this.satellite);

  @override
  void setTableTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<Record> transform,
  ) {
    satellite.setReplicationTransform(tableName, transform);
  }

  @override
  void clearTableTransform(QualifiedTablename tableName) {
    satellite.clearReplicationTransform(tableName);
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
Insertable<D> transformTableRecord<TableDsl extends Table, D, T extends Record>(
  TableInfo<TableDsl, D> table,
  D record,
  Insertable<D> Function(D) transformRow,
  List<String> immutableFields, {
  Insertable<D> Function(D)? toInsertable,
}) {
  // apply specified transformation
  final transformedParsedRow = transformRow(record);

  // validate transformed row
  table
      .validateIntegrity(transformedParsedRow, isInserting: true)
      .throwIfInvalid(transformedParsedRow);

  final Insertable<D> originalInsertable;
  if (record is Insertable<D>) {
    originalInsertable = record;
  } else {
    if (toInsertable == null) {
      throw ArgumentError(
        'toInsertable is required for non-insertable data classes',
      );
    }
    originalInsertable = toInsertable(record);
  }
  final originalCols = originalInsertable.toColumns(false);
  final transformedCols = transformedParsedRow.toColumns(false);

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
