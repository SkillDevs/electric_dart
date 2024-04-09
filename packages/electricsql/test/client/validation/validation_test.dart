import 'dart:typed_data';

import 'package:electricsql/src/client/validation/validation.dart';
import 'package:test/test.dart';

void main() {
  test(
      'validateRecordTransformation does not throw if immutable fields not changed',
      () {
    final originalRecord = {
      'id': 1,
      'name': 'test',
      'potato': 'banana',
      'data': Uint8List.fromList([1, 2]),
      'whatever': 'foo',
    };

    final transformedRecord = {
      'id': 1,
      'name': 'test-other',
      'potato': 'banana',
      'data': Uint8List.fromList([1, 2]),
      'whatever': 'foobar',
    };

    const immutableFields = ['id', 'potato'];
    final result = validateRecordTransformation(
      originalRecord,
      transformedRecord,
      immutableFields,
    );

    expect(result, transformedRecord);
  });

  test('validateRecordTransformation throws if immutable fields changed', () {
    final originalRecord = {
      'id': 1,
      'name': 'test',
      'potato': 'banana',
      'data': Uint8List.fromList([1, 2]),
      'whatever': 'foo',
    };

    final transformedRecord = {
      'id': 2,
      'name': 'test-other',
      'potato': 'banana',
      'data': Uint8List.fromList([1, 2]),
      'whatever': 'foobar',
    };

    const immutableFields = ['id', 'data'];

    expect(
      () => validateRecordTransformation(
        originalRecord,
        transformedRecord,
        immutableFields,
      ),
      throwsA(
        isA<InvalidRecordTransformationError>().having(
          (p0) => p0.message,
          'message',
          'Record transformation modified immutable fields: id, data',
        ),
      ),
    );
  });
}
