import 'dart:convert';

import 'package:electricsql/src/satellite/merge.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:test/test.dart';

void main() {
  test('merging entries: local no-op updates should cancel incoming delete',
      () {
    final pk = primaryKeyToStr({'id': 1});

    final local = <OplogEntry>[
      OplogEntry(
        rowid: 0,
        namespace: 'main',
        tablename: 'public',
        optype: OpType.update,
        timestamp: '1970-01-02T03:46:41.000Z', // 100001000 as a unix timestamp
        primaryKey: pk,
        newRow: json.encode({'id': 1}),
        oldRow: null,
        clearTags: json.encode(['common@100000000']),
      ),
    ];

    final remote = <OplogEntry>[
      OplogEntry(
        rowid: 0,
        namespace: 'main',
        tablename: 'public',
        optype: OpType.delete,
        timestamp: '1970-01-02T03:46:42.000Z', // 100002000 as a unix timestamp
        primaryKey: pk,
        oldRow: json.encode({'id': 1, 'value': 'TEST'}),
        clearTags: json.encode(['common@100000000']),
      ),
    ];

    final merged = mergeEntries('local', local, 'remote', remote);

    // Merge should resolve into the UPSERT for this row, since the remote DELETE didn't observe this local update
    expect(merged['main.public']![pk]!.optype, ChangesOpType.upsert);

    expect(merged['main.public']![pk]!.tags, ['local@100001000']);
    expect(merged['main.public']![pk]!.fullRow, {'id': 1, 'value': 'TEST'});
  });
}
