import 'package:electricsql/src/util/types.dart';

/// Validates that the given record transformation did not change any of the specified {@link immutableFields}.
/// @param originalRecord the source record
/// @param trnasformedRecord the transformed record
/// @param immutableFields the fields that should not have been modified
/// @returns the transformed record, validated such that no immutable fields are changed
///
/// @throws {@link InvalidRecordTransformationError}
/// Thrown if record transformation changed any of the specified {@link immutableFields}
T validateRecordTransformation<T extends DbRecord>(
  T originalRecord,
  T transformedRecord,
  List<String> immutableFields,
) {
  final modifiedImmutableFields = immutableFields.any(
    (key) => originalRecord[key] != transformedRecord[key],
  );
  if (modifiedImmutableFields) {
    throw InvalidRecordTransformationError(
      'Record transformation modified immutable fields: ${immutableFields.where((key) => originalRecord[key] != transformedRecord[key]).join(', ')}',
    );
  }

  return transformedRecord;
}

class InvalidRecordTransformationError implements Exception {
  final String message;

  InvalidRecordTransformationError(this.message);

  @override
  String toString() => 'InvalidRecordTransformationError: $message';
}
