import 'dart:convert';

import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/merge.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/satellite/process.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/converters/helpers.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

import '../util/sqlite.dart';
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

  Int64 toCommitTimestamp(String timestamp) =>
      Int64.ZERO + (DateTime.parse(timestamp).millisecondsSinceEpoch);

  test('merge can handle infinity values', () {
    final pk = primaryKeyToStr({'id': 1});

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

  test('merge works on oplog entries', () async {
    final db = openSqliteDbMemory();

    // Migrate the DB with the necessary tables and triggers
    migrateDb(db, kPersonTable);

    // Insert a row in the table
    final insertRowSQL =
        "INSERT INTO ${kPersonTable.tableName} (id, name, age, bmi) VALUES (9e999, 'John Doe', 30, 25.5)";
    db.execute(insertRowSQL);

    // Fetch the oplog entry for the inserted row
    final oplogRows =
        db.select('SELECT * FROM ${kSatelliteDefaults.oplogTable}').toList();

    expect(oplogRows.length, 1);

    final Map<String, Object?> opLogRowData = {...oplogRows.first};
    // Manually set the timestamp so that it's not null
    opLogRowData['timestamp'] =
        DateTime.fromMillisecondsSinceEpoch(0).toISOStringUTC();
    final oplogEntry = opLogEntryFromRow(opLogRowData);

    // Define a transaction that happened concurrently
    // and inserts a row with the same id but different values
    final tx = DataTransaction(
      lsn: kDefaultLogPos,
      commitTimestamp: toCommitTimestamp('1970-01-02T03:46:42.000Z'),
      changes: [
        DataChange(
          relation: kTestRelations[kPersonTable.tableName]!,
          type: DataChangeType.insert,
          record: {
            'age': 30,
            'bmi': 8e888,
            'id': 9e999,
            'name': 'John Doe',
          }, // fields must be ordered alphabetically to match the behavior of the triggers
          tags: [],
        ),
      ],
    );

    // Merge the oplog entry with the transaction
    final merged = mergeEntries(
      'local',
      [oplogEntry],
      'remote',
      fromTransaction(tx, kTestRelations),
      kTestRelations,
    );

    final pk = primaryKeyToStr({'id': 9e999});

    // the incoming transaction wins
    expect(
      merged['main.${kPersonTable.tableName}']![pk]!.optype,
      ChangesOpType.upsert,
    );
    expect(merged['main.${kPersonTable.tableName}']![pk]!.fullRow, {
      'id': 9e999,
      'name': 'John Doe',
      'age': 30,
      'bmi': double.infinity,
    });
  });
}
