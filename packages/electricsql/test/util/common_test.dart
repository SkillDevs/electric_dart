import 'dart:typed_data';

import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:test/test.dart';

void main() {
  test('test getWaiter onWait resolve', () async {
    final waiter = Waiter();

    final p = waiter.waitOn();

    waiter.complete();

    await p;

    expect(waiter.finished, isTrue);
  });

  test('test getWaiter onWait reject', () async {
    final waiter = Waiter();

    final p = waiter.waitOn();

    waiter.completeError(SatelliteException(SatelliteErrorCode.internal, ''));

    try {
      await p;
      fail('should have thrown');
    } catch (e) {
      expect(waiter.finished, isTrue);
    }
  });

  test('test type encoding/decoding works for arbitrary bytestrings', () {
    final blob = Uint8List.fromList([0, 1, 255, 245, 5, 155]);
    const expectedEncoding = '0001fff5059b';

    expect(blobToHexString(blob), expectedEncoding);
    expect(hexStringToBlob(expectedEncoding), blob);

    // should also handle empty bytestring
    expect(blobToHexString(Uint8List.fromList([])), '');
    expect(hexStringToBlob(''), Uint8List.fromList([]));
  });
}
