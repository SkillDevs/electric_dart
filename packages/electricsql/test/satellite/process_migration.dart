import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/notifiers/mock.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/satellite/process.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart' hide Change;
import 'package:equatable/equatable.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

import '../support/satellite_helpers.dart';
import 'common.dart';

late SatelliteTestContext context;

Future<void> runMigrations() async {
  await context.runMigrations();
}

DatabaseAdapter get adapter => context.adapter;
Migrator get migrator => context.migrator;
MockNotifier get notifier => context.notifier;
TableInfo get tableInfo => context.tableInfo;
DateTime get timestamp => context.timestamp;
SatelliteProcess get satellite => context.satellite;
MockSatelliteClient get client => context.client;
String get dbName => context.dbName;

late String clientId;
late DateTime txDate;
late QueryBuilder globalBuilder;
late String globalNamespace;

class ColumnInfo with EquatableMixin {
  String name;
  String type;
  int notnull;
  String? dfltValue;
  int pk;

  ColumnInfo({
    required this.name,
    required this.type,
    required this.notnull,
    required this.dfltValue,
    required this.pk,
  });

  @override
  List<Object?> get props => [name, type, notnull, dfltValue, pk];
}

Future<void> commonSetup(SatelliteTestContext context) async {
  final satellite = context.satellite;
  await satellite.start(context.authConfig);
  satellite.setToken(context.token);
  await satellite.connectWithBackoff();
  clientId = satellite.authState!.clientId; // store clientId in the context
  await populateDB(context);
  txDate = await satellite.performSnapshot();
  // Mimic Electric sending our own operations back
  // which serves as an acknowledgement (even though there is a separate ack also)
  // and leads to GC of the oplog
  final ackTx = Transaction(
    origin: satellite.authState!.clientId,
    commitTimestamp: Int64(txDate.millisecondsSinceEpoch),
    changes: [], // doesn't matter, only the origin and timestamp matter for GC of the oplog
    lsn: [],
  );
  await satellite.applyTransaction(ackTx);
}

void processMigrationTests({
  required SatelliteTestContext Function() getContext,
  required String namespace,
  required QueryBuilder builder,
  required GetMatchingShadowEntries getMatchingShadowEntries,
}) {
  setUp(() async {
    context = getContext();
    globalBuilder = builder;
    globalNamespace = namespace;
  });

  test('setup populates DB', () async {
    const sql = 'SELECT * FROM parent';
    final rows = await adapter.query(Statement(sql));
    expect(rows, [
      {
        'id': 1,
        'value': 'local',
        'other': null,
      },
      {
        'id': 2,
        'value': 'local',
        'other': null,
      },
    ]);
  });

  test('apply migration containing only DDL', () async {
    // const { satellite, adapter, txDate } = t.context
    final timestamp = txDate.millisecondsSinceEpoch;

    final rowsBeforeMigration = await fetchParentRows(adapter);

    final migrationTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(timestamp),
      changes: [createTable, addColumn],
      lsn: [],
      // starts at 3, because the app already defines 2 migrations
      // (see test/support/migrations/migrations.js)
      // which are loaded when Satellite is started
      migrationVersion: '3',
    );

    // Apply the migration transaction
    await satellite.applyTransaction(migrationTx);

    // Check that the migration was successfully applied
    await checkMigrationIsApplied();

    // Check that the existing rows are still there and are unchanged
    final rowsAfterMigration = await fetchParentRows(adapter);
    final expectedRowsAfterMigration = rowsBeforeMigration.map((Row row) {
      return {
        ...row,
        'baz': null,
      };
    }).toList();

    expect(rowsAfterMigration, expectedRowsAfterMigration);
  });

  test('apply migration containing DDL and non-conflicting DML', () async {
    /*
     Test migrations containing non-conflicting DML statements and some DDL statements
     - Process the following migration tx: <DML 1> <DDL 1> <DML 2>
        - DML 1 is:
           insert non-conflicting row in existing table
           non-conflict update to existing row
           delete row
        - DDL 1 is:
            Add column to table that is affected by the statements in DML 1
            Create new table
        - DML 2 is:
            insert row in extended table with value for new column
            insert row in extended table without a value for the new column
            Insert some rows in newly created table
     - Check that the migration was successfully applied on the local DB
     - Check the modifications (insert, update, delete) to the rows
 */

    final timestamp = txDate.millisecondsSinceEpoch;

    final txTags = [generateTag('remote', txDate)];
    DataChange mkInsertChange(Row record) {
      return DataChange(
        type: DataChangeType.insert,
        relation: kTestRelations['parent']!,
        record: record,
        oldRecord: {},
        tags: txTags,
      );
    }

    final insertRow = {
      'id': 3,
      'value': 'remote',
      'other': 1,
    };

    final insertChange = mkInsertChange(insertRow);

    final oldUpdateRow = {
      'id': 1,
      'value': 'local',
      'other': null,
    };

    final updateRow = {
      'id': 1,
      'value': 'remote',
      'other': 5,
    };

    final updateChange = DataChange(
      //type: DataChangeType.INSERT, // insert since `opLogEntryToChange` also transforms update optype into insert
      type: DataChangeType.update,
      relation: kTestRelations['parent']!,
      record: updateRow,
      oldRecord: oldUpdateRow,
      tags: txTags,
    );

    // Delete overwrites the insert for row with id 2
    // Thus, it overwrites the shadow tag for that row
    // ignore: unused_local_variable
    final localEntries = await satellite.getEntries();
    final shadowEntryForRow2 = await getMatchingShadowEntries(
      adapter,
      //TODO(dart): localEntries should have elements. buggy in upstream
      // oplog: localEntries[1],
    ); // shadow entry for insert of row with id 2
    final shadowTagsRow2 =
        (json.decode(shadowEntryForRow2[0].tags) as List<dynamic>)
            .cast<String>();

    final deleteRow = {
      'id': 2,
      'value': 'local',
      'other': null,
    };

    final deleteChange = DataChange(
      type: DataChangeType.delete,
      relation: kTestRelations['parent']!,
      oldRecord: deleteRow,
      tags: shadowTagsRow2,
    );

    final insertExtendedRow = {
      'id': 4,
      'value': 'remote',
      'other': 6,
      'baz': 'foo',
    };
    final insertExtendedChange = DataChange(
      type: DataChangeType.insert,
      relation: addColumnRelation,
      record: insertExtendedRow,
      oldRecord: {},
      tags: txTags,
    );

    final insertExtendedWithoutValueRow = {
      'id': 5,
      'value': 'remote',
      'other': 7,
    };
    final insertExtendedWithoutValueChange = DataChange(
      type: DataChangeType.insert,
      relation: addColumnRelation,
      record: insertExtendedWithoutValueRow,
      oldRecord: {},
      tags: txTags,
    );

    final insertInNewTableRow = {
      'id': '1',
      'foo': 1,
      'bar': '2',
    };
    final insertInNewTableChange = DataChange(
      type: DataChangeType.insert,
      relation: newTableRelation,
      record: insertInNewTableRow,
      oldRecord: {},
      tags: txTags,
    );

    final dml1 = [insertChange, updateChange, deleteChange];
    final ddl1 = [addColumn, createTable];
    final dml2 = [
      insertExtendedChange,
      insertExtendedWithoutValueChange,
      insertInNewTableChange,
    ];

    final migrationTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(timestamp),
      changes: [...dml1, ...ddl1, ...dml2],
      lsn: [],
      migrationVersion: '4',
    );

    final rowsBeforeMigration = await fetchParentRows(adapter);

    // For each schema change, Electric sends a `SatRelation` message
    // before sending a DML operation that depends on a new or modified schema.
    // The `SatRelation` message is handled by `_updateRelations` in order
    // to update Satellite's relations
    await satellite.updateRelations(addColumnRelation);
    await satellite.updateRelations(newTableRelation);

    // Apply the migration transaction
    await satellite.applyTransaction(migrationTx);

    // Check that the migration was successfully applied
    await checkMigrationIsApplied();

    // Check that the existing rows are still there and are unchanged
    final rowsAfterMigration = await fetchParentRows(adapter);
    final List<Row> expectedRowsAfterMigration = [
      ...[
        ...rowsBeforeMigration.where(
          (Row r) =>
              r['id'] != deleteRow['id'] && r['id'] != oldUpdateRow['id'],
        ),
        insertRow,
        updateRow,
        insertExtendedWithoutValueRow,
      ].map((Row row) {
        return {
          ...row,
          'baz': null,
        };
      }),
      insertExtendedRow,
    ];

    expect(rowsAfterMigration.toSet(), expectedRowsAfterMigration.toSet());

    // Check the row that was inserted in the new table
    final newTableRows = await adapter.query(
      Statement(
        'SELECT * FROM "NewTable"',
      ),
    );

    expect(newTableRows.length, 1);
    expect(newTableRows[0], insertInNewTableRow);
  });

  test('apply migration containing DDL and conflicting DML', () async {
    // Same as previous test but DML contains some conflicting operations

    // Fetch the shadow tag for row 1 such that delete will overwrite it
    // ignore: unused_local_variable
    final localEntries = await satellite.getEntries();
    final shadowEntryForRow1 = await getMatchingShadowEntries(
      adapter,
      // TODO(dart): Buggy in upstream
      //oplog: localEntries[0]
    ); // shadow entry for insert of row with id 1
    final shadowTagsRow1 =
        (json.decode(shadowEntryForRow1[0].tags) as List<dynamic>)
            .cast<String>();

    // Locally update row with id 1
    await adapter.runInTransaction(
      [
        Statement(
          "UPDATE parent SET value = 'still local', other = 5 WHERE id = 1;",
        ),
      ],
    );

    await satellite.performSnapshot();

    // Now receive a concurrent delete of that row
    // such that it deletes the row with id 1 that was initially inserted
    final timestamp = txDate.millisecondsSinceEpoch;
    //const txTags = [ generateTag('remote', txDate) ]

    final deleteRow = {
      'id': 1,
      'value': 'local',
      'other': null,
    };

    final deleteChange = DataChange(
      type: DataChangeType.delete,
      relation: kTestRelations['parent']!,
      oldRecord: deleteRow,
      tags: shadowTagsRow1,
    );

    // Process the incoming delete
    final ddl = [addColumn, createTable];
    final dml = [deleteChange];

    final migrationTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(timestamp),
      changes: [...ddl, ...dml],
      lsn: [],
      migrationVersion: '5',
    );

    final rowsBeforeMigration = await fetchParentRows(adapter);
    final rowsBeforeMigrationExceptConflictingRow = rowsBeforeMigration.where(
      (r) => r['id'] != deleteRow['id'],
    );

    // For each schema change, Electric sends a `SatRelation` message
    // before sending a DML operation that depends on a new or modified schema.
    // The `SatRelation` message is handled by `_updateRelations` in order
    // to update Satellite's relations.
    // In this case, the DML operation deletes a row in `parent` table
    // so we receive a `SatRelation` message for that table
    await satellite.updateRelations(addColumnRelation);

    // Apply the migration transaction
    await satellite.applyTransaction(migrationTx);

    // Check that the migration was successfully applied
    await checkMigrationIsApplied();

    // The local update and remote delete happened concurrently
    // Check that the update wins
    final rowsAfterMigration = await fetchParentRows(adapter);
    final newRowsExceptConflictingRow =
        rowsAfterMigration.where((r) => r['id'] != deleteRow['id']);
    final conflictingRow =
        rowsAfterMigration.firstWhere((r) => r['id'] == deleteRow['id']);

    expect(
      rowsBeforeMigrationExceptConflictingRow.map((r) {
        return {
          'baz': null,
          ...r,
        };
      }).toSet(),
      newRowsExceptConflictingRow.toSet(),
    );

    expect(conflictingRow, {
      'id': 1,
      'value': 'still local',
      'other': 5,
      'baz': null,
    });
  });

  test('apply migration and concurrent transaction', () async {
    final timestamp = txDate.millisecondsSinceEpoch;
    const remoteA = 'remoteA';
    const remoteB = 'remoteB';
    final txTagsRemoteA = [generateTag(remoteA, txDate)];
    final txTagsRemoteB = [generateTag(remoteB, txDate)];

    DataChange mkInsertChange(Row record, List<String> tags) {
      return DataChange(
        type: DataChangeType.insert,
        relation: kTestRelations['parent']!,
        record: record,
        oldRecord: {},
        tags: tags,
      );
    }

    final insertRowA = {
      'id': 3,
      'value': 'remote A',
      'other': 8,
    };

    final insertRowB = {
      'id': 3,
      'value': 'remote B',
      'other': 9,
    };

    // Make 2 concurrent insert changes.
    // They are concurrent because both remoteA and remoteB
    // generated the changes at `timestamp`
    final insertChangeA = mkInsertChange(insertRowA, txTagsRemoteA);
    final insertChangeB = mkInsertChange(insertRowB, txTagsRemoteB);

    final txA = Transaction(
      origin: remoteA,
      commitTimestamp: Int64(timestamp),
      changes: [insertChangeA],
      lsn: [],
    );

    final ddl = [addColumn, createTable];

    final txB = Transaction(
      origin: remoteB,
      commitTimestamp: Int64(timestamp),
      changes: [...ddl, insertChangeB],
      lsn: [],
      migrationVersion: '6',
    );

    final rowsBeforeMigration = await fetchParentRows(adapter);

    // For each schema change, Electric sends a `SatRelation` message
    // before sending a DML operation that depends on a new or modified schema.
    // The `SatRelation` message is handled by `_updateRelations` in order
    // to update Satellite's relations.
    // In this case, the DML operation adds a row in `parent` table
    // so we receive a `SatRelation` message for that table
    await satellite.updateRelations(addColumnRelation);

    // Apply the concurrent transactions
    await satellite.applyTransaction(txB);
    await satellite.applyTransaction(txA);

    // Check that the migration was successfully applied
    await checkMigrationIsApplied();

    // Check that one of the two insertions won
    final rowsAfterMigration = await fetchParentRows(adapter);
    Row extendRow(Row r) {
      return {
        ...r,
        'baz': null,
      };
    }

    final extendedRows = rowsBeforeMigration.map(extendRow);

    // Check that all rows now have an additional column
    expect(
      rowsAfterMigration.where((r) => r['id'] != insertRowA['id']),
      extendedRows,
    );

    final conflictingRow =
        rowsAfterMigration.firstWhere((r) => r['id'] == insertRowA['id']);

    const mapEq = MapEquality<String, Object?>();
    // Now also check the row that was concurrently inserted
    expect(
      mapEq.equals(conflictingRow, extendRow(insertRowA)) ||
          mapEq.equals(conflictingRow, extendRow(insertRowB)),
      isTrue,
    );
  });

  final migrationWithFKs = <SchemaChange>[
    SchemaChange(
      migrationType: SatOpMigrate_Type.CREATE_TABLE,
      sql: '''
    CREATE TABLE "test_items" (
      "id" TEXT NOT NULL,
      CONSTRAINT "test_items_pkey" PRIMARY KEY ("id")
    );
    ''',
      table: SatOpMigrate_Table(
        name: 'test_items',
        columns: [
          SatOpMigrate_Column(
            name: 'id',
            sqliteType: 'TEXT',
            pgType: SatOpMigrate_PgColumnType(name: 'TEXT'),
          ),
        ],
        fks: [],
        pks: ['id'],
      ),
    ),
    SchemaChange(
      migrationType: SatOpMigrate_Type.CREATE_TABLE,
      sql: '''
    CREATE TABLE "test_other_items" (
      "id" TEXT NOT NULL,
      "item_id" TEXT,
      -- CONSTRAINT "test_other_items_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "test_items" ("id"),
      CONSTRAINT "test_other_items_pkey" PRIMARY KEY ("id")
    );
    ''',
      table: SatOpMigrate_Table(
        name: 'test_other_items',
        columns: [
          SatOpMigrate_Column(
            name: 'id',
            sqliteType: 'TEXT',
            pgType: SatOpMigrate_PgColumnType(name: 'TEXT'),
          ),
          SatOpMigrate_Column(
            name: 'item_id',
            sqliteType: 'TEXT',
            pgType: SatOpMigrate_PgColumnType(name: 'TEXT'),
          ),
        ],
        fks: [
          SatOpMigrate_ForeignKey(
            fkCols: ['item_id'],
            pkTable: 'test_items',
            pkCols: ['id'],
          ),
        ],
        pks: ['id'],
      ),
    ),
  ];

  test('apply another migration', () async {
    final migrationTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      changes: migrationWithFKs,
      lsn: [],
      // starts at 3, because the app already defines 2 migrations
      // (see test/support/migrations/migrations.js)
      // which are loaded when Satellite is started
      migrationVersion: '3',
    );

    // Apply the migration transaction
    await satellite.applyTransaction(migrationTx);

    await assertDbHasTables(['test_items', 'test_other_items']);
  });
}

Future<void> populateDB(SatelliteTestContext context) async {
  final adapter = context.adapter;

  final stmts = <Statement>[];

  stmts.add(
    Statement(
      "INSERT INTO parent (id, value, other) VALUES (1, 'local', null);",
    ),
  );
  stmts.add(
    Statement(
      "INSERT INTO parent (id, value, other) VALUES (2, 'local', null);",
    ),
  );
  await adapter.runInTransaction(stmts);
}

Future<void> assertDbHasTables(List<String> tables) async {
  final schemaRows = await adapter.query(globalBuilder.getLocalTableNames());

  final tableNames = Set<String>.from(
    schemaRows.map((r) => r['name']! as String),
  );
  for (final tbl in tables) {
    expect(tableNames, contains(tbl));
  }
}

Future<List<ColumnInfo>> getTableInfo(QualifiedTablename table) async {
  final rows = await adapter.query(globalBuilder.getTableInfo(table));

  return rows.map((r) {
    return ColumnInfo(
      name: r['name']! as String,
      type: r['type']! as String,
      notnull: r['notnull']! as int,
      dfltValue: r['dflt_value'] as String?,
      pk: r['pk']! as int,
    );
  }).toList();
}

final createTable = SchemaChange(
  table: SatOpMigrate_Table(
    name: 'NewTable',
    columns: [
      SatOpMigrate_Column(
        name: 'id',
        sqliteType: 'TEXT',
        pgType: SatOpMigrate_PgColumnType(name: 'TEXT'),
      ),
      SatOpMigrate_Column(
        name: 'foo',
        sqliteType: 'INTEGER',
        pgType: SatOpMigrate_PgColumnType(name: 'INTEGER'),
      ),
      SatOpMigrate_Column(
        name: 'bar',
        sqliteType: 'TEXT',
        pgType: SatOpMigrate_PgColumnType(name: 'TEXT'),
      ),
    ],
    fks: [],
    pks: ['id'],
  ),
  migrationType: SatOpMigrate_Type.CREATE_TABLE,
  sql: '''
    CREATE TABLE "NewTable"(
         id TEXT NOT NULL,
         foo INTEGER,
         bar TEXT,
         PRIMARY KEY(id)
       );''',
);

final addColumn = SchemaChange(
  table: SatOpMigrate_Table(
    name: 'parent',
    columns: [
      SatOpMigrate_Column(
        name: 'id',
        sqliteType: 'INTEGER',
        pgType: SatOpMigrate_PgColumnType(name: 'INTEGER'),
      ),
      SatOpMigrate_Column(
        name: 'value',
        sqliteType: 'TEXT',
        pgType: SatOpMigrate_PgColumnType(name: 'TEXT'),
      ),
      SatOpMigrate_Column(
        name: 'other',
        sqliteType: 'INTEGER',
        pgType: SatOpMigrate_PgColumnType(name: 'INTEGER'),
      ),
      SatOpMigrate_Column(
        name: 'baz',
        sqliteType: 'TEXT',
        pgType: SatOpMigrate_PgColumnType(name: 'TEXT'),
      ),
    ],
    fks: [],
    pks: ['id'],
  ),
  migrationType: SatOpMigrate_Type.ALTER_ADD_COLUMN,
  sql: 'ALTER TABLE parent ADD baz TEXT',
);

final addColumnRelation = Relation(
  id: 2000, // doesn't matter
  schema: 'public',
  table: 'parent',
  tableType: SatRelation_RelationType.TABLE,
  columns: [
    RelationColumn(
      name: 'id',
      type: 'INTEGER',
      isNullable: false,
      primaryKey: 1,
    ),
    RelationColumn(
      name: 'value',
      type: 'TEXT',
      isNullable: true,
      primaryKey: null,
    ),
    RelationColumn(
      name: 'other',
      type: 'INTEGER',
      isNullable: true,
      primaryKey: null,
    ),
    RelationColumn(
      name: 'baz',
      type: 'TEXT',
      isNullable: true,
      primaryKey: null,
    ),
  ],
);
final newTableRelation = Relation(
  id: 2001, // doesn't matter
  schema: 'public',
  table: 'NewTable',
  tableType: SatRelation_RelationType.TABLE,
  columns: [
    RelationColumn(
      name: 'id',
      type: 'TEXT',
      isNullable: false,
      primaryKey: 1,
    ),
    RelationColumn(
      name: 'foo',
      type: 'INTEGER',
      isNullable: true,
      primaryKey: null,
    ),
    RelationColumn(
      name: 'bar',
      type: 'TEXT',
      isNullable: true,
      primaryKey: null,
    ),
  ],
);

Future<void> checkMigrationIsApplied() async {
  await assertDbHasTables(['parent', 'child', 'NewTable']);

  final newTableInfo =
      await getTableInfo(QualifiedTablename(globalNamespace, 'NewTable'));

  expect(newTableInfo.toSet(), {
    // id, foo, bar
    ColumnInfo(
      name: 'id',
      type: 'TEXT',
      notnull: 1,
      dfltValue: null,
      pk: 1,
    ),
    ColumnInfo(
      name: 'foo',
      type: 'INTEGER',
      notnull: 0,
      dfltValue: null,
      pk: 0,
    ),
    ColumnInfo(
      name: 'bar',
      type: 'TEXT',
      notnull: 0,
      dfltValue: null,
      pk: 0,
    ),
  });

  final parentTableInfo =
      await getTableInfo(QualifiedTablename(globalNamespace, 'parent'));
  final parentTableHasColumn = parentTableInfo.any((col) {
    return col.name == 'baz' &&
        col.type == 'TEXT' &&
        col.notnull == 0 &&
        col.dfltValue == null &&
        col.pk == 0;
  });

  expect(parentTableHasColumn, isTrue);
}

Future<List<Row>> fetchParentRows(DatabaseAdapter adapter) async {
  final res = await adapter.query(
    Statement(
      'SELECT * FROM parent',
    ),
  );

  return res.toList();
}
