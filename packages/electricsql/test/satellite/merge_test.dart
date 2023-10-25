import 'dart:convert';

import 'package:electricsql/src/satellite/merge.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  test('merging entries: local no-op updates should cancel incoming delete',
      () {
    final pk = primaryKeyToStr({'id': 1});

    final local = <OplogEntry>[
      OplogEntry(
        rowid: 0,
        namespace: 'main',
        tablename: 'parent',
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
        tablename: 'parent',
        optype: OpType.delete,
        timestamp: '1970-01-02T03:46:42.000Z', // 100002000 as a unix timestamp
        primaryKey: pk,
        oldRow: json.encode({'id': 1, 'value': 'TEST'}),
        clearTags: json.encode(['common@100000000']),
      ),
    ];

    final merged =
        mergeEntries('local', local, 'remote', remote, kTestRelations);

    // Merge should resolve into the UPSERT for this row, since the remote DELETE didn't observe this local update
    expect(merged['main.parent']![pk]!.optype, ChangesOpType.upsert);

    expect(merged['main.parent']![pk]!.tags, ['local@100001000']);
    expect(merged['main.parent']![pk]!.fullRow, {'id': 1, 'value': 'TEST'});
  });

  test('merge can handle infinity values', () {
    final pk = primaryKeyToStr({'id': 1});

    Int64 toCommitTimestamp(String timestamp) =>
        Int64.ZERO + (DateTime.parse(timestamp).millisecondsSinceEpoch);

    final DataTransaction tx1 = DataTransaction(
      lsn: kDefaultLogPos,
      commitTimestamp: toCommitTimestamp('1970-01-02T03:46:41.000Z'),
      changes: [
        DataChange(
          relation: kTestRelations['floatTable']!,
          type: DataChangeType.insert,
          record: {'id': 1, 'value': double.infinity},
          tags: [],
        ),
      ],
    );

    final DataTransaction tx2 = DataTransaction(
      lsn: kDefaultLogPos,
      commitTimestamp: toCommitTimestamp('1970-01-02T03:46:42.000Z'),
      changes: [
        DataChange(
          relation: kTestRelations['floatTable']!,
          type: DataChangeType.insert,
          record: {'id': 1, 'value': double.negativeInfinity},
          tags: [],
        ),
      ],
    );

    // we go through `fromTransaction` on purpose
    // in order to also test serialisation/deserialisation of the rows
    final entry1 = fromTransaction(tx1, kTestRelations);
    final entry2 = fromTransaction(tx2, kTestRelations);

    final merged =
        mergeEntries('local', entry1, 'remote', entry2, kTestRelations);

    // tx2 should win because tx1 and tx2 happened concurrently
    // but the timestamp of tx2 > tx1
    expect(merged['main.floatTable']![pk]!.optype, ChangesOpType.upsert);
    expect(merged['main.floatTable']![pk]!.fullRow, {
      'id': 1,
      'value': double.negativeInfinity,
    });
  });

  test('merge can handle NaN values', () {
    final pk = primaryKeyToStr({'id': 1});

    Int64 toCommitTimestamp(String timestamp) =>
        Int64.ZERO + (DateTime.parse(timestamp).millisecondsSinceEpoch);

    final DataTransaction tx1 = DataTransaction(
      lsn: kDefaultLogPos,
      commitTimestamp: toCommitTimestamp('1970-01-02T03:46:41.000Z'),
      changes: [
        DataChange(
          relation: kTestRelations['floatTable']!,
          type: DataChangeType.insert,
          record: {'id': 1, 'value': 5.0},
          tags: [],
        ),
      ],
    );

    final DataTransaction tx2 = DataTransaction(
      lsn: kDefaultLogPos,
      commitTimestamp: toCommitTimestamp('1970-01-02T03:46:42.000Z'),
      changes: [
        DataChange(
          relation: kTestRelations['floatTable']!,
          type: DataChangeType.insert,
          record: {'id': 1, 'value': double.nan},
          tags: [],
        ),
      ],
    );

    // we go through `fromTransaction` on purpose
    // in order to also test serialisation/deserialisation of the rows
    final entry1 = fromTransaction(tx1, kTestRelations);
    final entry2 = fromTransaction(tx2, kTestRelations);

    final merged =
        mergeEntries('local', entry1, 'remote', entry2, kTestRelations);

    // tx2 should win because tx1 and tx2 happened concurrently
    // but the timestamp of tx2 > tx1
    expect(merged['main.floatTable']![pk]!.optype, ChangesOpType.upsert);

    final fullRow = merged['main.floatTable']![pk]!.fullRow;
    expect(fullRow.length, 2);
    expect(fullRow['id'], 1);
    expect((fullRow['value']! as double).isNaN, isTrue);
  });
}
