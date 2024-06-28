import 'dart:convert';
import 'dart:typed_data';

import 'package:electricsql/drivers/drivers.dart';
import 'package:electricsql/drivers/sqlite3.dart';
import 'package:electricsql/src/drivers/drift/drift_adapter.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/merge.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/satellite/process.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/converters/helpers.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:electricsql/util.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

import '../support/postgres.dart';
import '../util/sqlite.dart';
import 'common.dart';

final qualifiedMergeTable =
    const QualifiedTablename('main', 'mergeTable').toString();

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
    final qualifiedTableName =
        const QualifiedTablename('main', 'parent').toString();
    expect(merged[qualifiedTableName]![pk]!.optype, ChangesOpType.upsert);

    expect(merged[qualifiedTableName]![pk]!.tags, ['local@100001000']);
    expect(
      merged[qualifiedTableName]![pk]!.fullRow,
      {'id': 1, 'value': 'TEST'},
    );
  });

  test('merge can handle infinity values', () {
    _mergeTableTest(
      initial: {'real': double.infinity},
      incoming: {'real': double.negativeInfinity},
      expected: {'real': double.negativeInfinity},
    );
  });

  test('merge can handle NaN values', () {
    _mergeTableTest(
      initial: {'real': 5.0},
      incoming: {'real': double.nan},
      expected: {'real': double.nan},
    );
  });

  test('merge can handle BigInt (INT8 pgtype) values', () {
    // Big ints are serialized as strings in the oplog
    _mergeTableTest(
      initial: {'int8': '3'},
      incoming: {'int8': '9223372036854775807'},
      expected: {'int8': BigInt.parse('9223372036854775807')},
    );
  });

  test('merge can handle BigInt (BIGINT pgtype) values', () {
    // Big ints are serialized as strings in the oplog
    _mergeTableTest(
      initial: {'bigint': '-5'},
      incoming: {'bigint': '-9223372036854775808'},
      expected: {'bigint': BigInt.parse('-9223372036854775808')},
    );
  });

  Future<List<dynamic>> setupSqlite() async {
    final db = openSqliteDbMemory();
    addTearDown(() => db.dispose());
    const namespace = 'main';
    final defaults = satelliteDefaults(namespace);
    return [SqliteAdapter(db), kSqliteQueryBuilder, namespace, defaults];
  }

  int port = 4700;
  Future<List<dynamic>> setupPostgres() async {
    final pgEmbedded = await makePgDatabase('merge-tests', port++);
    final dbName = 'merge-test-${randomValue()}';
    final scopedDb = await initScopedPostgresDatabase(pgEmbedded, dbName);
    final db = scopedDb.db;
    addTearDown(() async {
      await scopedDb.dispose();
      await pgEmbedded.dispose();
    });
    const namespace = 'public';
    final defaults = satelliteDefaults(namespace);
    return [DriftAdapter(db), kPostgresQueryBuilder, namespace, defaults];
  }

  final envs = <(Dialect dialect, Future<List<dynamic>> Function() setup)>[
    (Dialect.sqlite, setupSqlite),
    (Dialect.postgres, setupPostgres),
  ];

  for (final env in envs) {
    // ignore: unused_local_variable
    final dialect = env.$1;
    final setup = env.$2;
    test(
      'merge works on oplog entries',
      tags: [
        if (dialect == Dialect.postgres) 'postgres',
      ],
      () async {
        final [_adapter, _builder, _namespace, _defaults] = await setup();

        final adapter = _adapter as DatabaseAdapter;
        final builder = _builder as QueryBuilder;
        final namespace = _namespace as String;
        final defaults = _defaults as SatelliteOpts;

        // Migrate the DB with the necessary tables and triggers
        final personTable = getPersonTable(namespace);
        final qualifiedPersonTable = personTable.qualifiedTableName;
        await migrateDb(adapter, personTable, builder);

        // Insert a row in the table
        final insertRowSQL =
            '''INSERT INTO $qualifiedPersonTable (id, name, age, bmi, int8, blob) VALUES (54321, 'John Doe', 30, 25.5, 7, ${builder.hexValue('0001ff')})''';
        await adapter.run(Statement(insertRowSQL));

        // Fetch the oplog entry for the inserted row
        final oplogTable = '${defaults.oplogTable}';
        final oplogRows = await adapter.query(
          Statement(
            'SELECT * FROM $oplogTable',
          ),
        );

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
              relation: kTestRelations[qualifiedPersonTable.tablename]!,
              type: DataChangeType.insert,
              record: {
                // fields must be ordered alphabetically to match the behavior of the triggers
                'age': 30,
                'blob': Uint8List.fromList([0, 1, 255]),
                'bmi': 21.3,
                'id': 54321,
                'int8':
                    '224', // Big ints are serialized as strings in the oplog
                'name': 'John Doe',
              },
              tags: [],
            ),
          ],
        );

        // Merge the oplog entry with the transaction
        final merged = mergeEntries(
          'local',
          [oplogEntry],
          'remote',
          fromTransaction(tx, kTestRelations, namespace),
          kTestRelations,
        );

        final pk = primaryKeyToStr({'id': 54321});

        // the incoming transaction wins
        final qualifiedTableName = qualifiedPersonTable.toString();
        expect(
          merged[qualifiedTableName]![pk]!.optype,
          ChangesOpType.upsert,
        );
        expect(merged[qualifiedTableName]![pk]!.fullRow, {
          'id': 54321,
          'name': 'John Doe',
          'age': 30,
          'blob': Uint8List.fromList([0, 1, 255]),
          'bmi': 21.3,
          'int8': BigInt.parse('224'),
        });
      },
    );
  }
}

Int64 toCommitTimestamp(String timestamp) =>
    Int64.ZERO + (DateTime.parse(timestamp).millisecondsSinceEpoch);

/// Merges two secuential transactions over the same row
/// and checks that the value is merged correctly
/// The operation is over the "mergeTable" table in the
/// database schema
void _mergeTableTest({
  required Map<String, Object?> initial,
  required Map<String, Object?> incoming,
  required Map<String, Object?> expected,
}) {
  if (initial.containsKey('id')) {
    throw Exception('id must not be provided in initial');
  }
  if (incoming.containsKey('id')) {
    throw Exception('id must not be provided in incoming');
  }
  if (expected.containsKey('id')) {
    throw Exception('id must not be provided in expected');
  }

  const pkId = 1;
  final pk = primaryKeyToStr({'id': pkId});

  final DataTransaction tx1 = DataTransaction(
    lsn: kDefaultLogPos,
    commitTimestamp: toCommitTimestamp('1970-01-02T03:46:41.000Z'),
    changes: [
      DataChange(
        relation: kTestRelations['mergeTable']!,
        type: DataChangeType.insert,
        record: {...initial, 'id': pkId},
        tags: [],
      ),
    ],
  );

  final DataTransaction tx2 = DataTransaction(
    lsn: kDefaultLogPos,
    commitTimestamp: toCommitTimestamp('1970-01-02T03:46:42.000Z'),
    changes: [
      DataChange(
        relation: kTestRelations['mergeTable']!,
        type: DataChangeType.insert,
        record: {
          ...incoming,
          'id': 1,
        },
        tags: [],
      ),
    ],
  );

  // we go through `fromTransaction` on purpose
  // in order to also test serialisation/deserialisation of the rows
  final entry1 = fromTransaction(tx1, kTestRelations, 'main');
  final entry2 = fromTransaction(tx2, kTestRelations, 'main');

  final merged =
      mergeEntries('local', entry1, 'remote', entry2, kTestRelations);

  // tx2 should win because tx1 and tx2 happened concurrently
  // but the timestamp of tx2 > tx1
  expect(merged[qualifiedMergeTable]![pk]!.optype, ChangesOpType.upsert);

  final fullRow = merged[qualifiedMergeTable]![pk]!.fullRow;
  expect(fullRow['id'], pkId);

  fullRow.remove('id');

  expect(fullRow.length, expected.length);

  for (final key in expected.keys) {
    final expectedValue = expected[key];
    if (expectedValue is double && expectedValue.isNaN) {
      expect(fullRow[key], isNaN);
    } else {
      expect(fullRow[key], expectedValue);
    }
  }
}
