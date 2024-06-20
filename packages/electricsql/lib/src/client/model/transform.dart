import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/validation/validation.dart';
import 'package:electricsql/util.dart';

abstract class IReplicationTransformManager {
  void setTableTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<DbRecord> transform,
  );

  void clearTableTransform(QualifiedTablename tableName);
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
D transformTableRecord<D>(
  D record,
  D Function(D) transformRow,
  List<String> immutableFields, {
  required void Function(D) validateFun,
  required Map<String, Object?> Function(D) toRecord,
}) {
  // apply specified transformation
  final transformedParsedRow = transformRow(record);

  // validate transformed row
  validateFun(transformedParsedRow);

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
