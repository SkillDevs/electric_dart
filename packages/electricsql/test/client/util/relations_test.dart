import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/client/util/relations.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:test/test.dart';

late SatOpMigrate_Table otherTable;
late SatOpMigrate_Table fooTable;
late SatOpMigrate_Table itemsTable;
late List<SatOpMigrate_Table> tables;

void main() {
  setUp(() {
    otherTable = SatOpMigrate_Table(
      name: 'other',
      columns: [
        SatOpMigrate_Column(
          name: 'other_id',
          sqliteType: 'TEXT',
          pgType: SatOpMigrate_PgColumnType(
            name: 'text',
            array: [],
            size: [],
          ),
        ),
      ],
      fks: [],
      pks: ['other_id'],
    );

    fooTable = SatOpMigrate_Table(
      name: 'foo',
      columns: [
        SatOpMigrate_Column(
          name: 'foo_id',
          sqliteType: 'TEXT',
          pgType: SatOpMigrate_PgColumnType(
            name: 'text',
            array: [],
            size: [],
          ),
        ),
        SatOpMigrate_Column(
          name: 'otherr',
          sqliteType: 'TEXT',
          pgType: SatOpMigrate_PgColumnType(
            name: 'text',
            array: [],
            size: [],
          ),
        ),
      ],
      fks: [
        SatOpMigrate_ForeignKey(
          fkCols: ['otherr'],
          pkTable: 'other',
          pkCols: ['other_id'],
        ),
      ],
      pks: ['foo_id'],
    );

    itemsTable = SatOpMigrate_Table(
      name: 'items',
      columns: [
        SatOpMigrate_Column(
          name: 'items_id',
          sqliteType: 'TEXT',
          pgType: SatOpMigrate_PgColumnType(
            name: 'text',
            array: [],
            size: [],
          ),
        ),
        SatOpMigrate_Column(
          name: 'other_id1',
          sqliteType: 'TEXT',
          pgType: SatOpMigrate_PgColumnType(
            name: 'text',
            array: [],
            size: [],
          ),
        ),
        SatOpMigrate_Column(
          name: 'other_id2',
          sqliteType: 'TEXT',
          pgType: SatOpMigrate_PgColumnType(
            name: 'text',
            array: [],
            size: [],
          ),
        ),
      ],
      fks: [
        SatOpMigrate_ForeignKey(
          fkCols: ['other_id1'],
          pkTable: 'other',
          pkCols: ['other_id'],
        ),
        SatOpMigrate_ForeignKey(
          fkCols: ['other_id2'],
          pkTable: 'other',
          pkCols: ['other_id'],
        ),
      ],
      pks: ['items_id'],
    );

    tables = [otherTable, fooTable, itemsTable];
  });

  test('createRelationsFromTable creates no relations on table without FKs',
      () {
    final KeyedTables keyedTables = keyBy(tables);
    final relations = createRelationsFromTable(otherTable, keyedTables);
    expect(
      relations.length,
      0,
      reason: 'Expected no relations on table without FKs',
    );
  });

  /*
 * When a child table has a FK to a parent table
 * we create a relation from the child table to the parent table
 * and we also create the reserve relation from the parent table to the child table.
 * The reverse relation is needed to be able to
 * follow the relation in both directions.
 *
 * If there is only a single relation from the child table to the parent table
 * then that relation is named after the parent table (except if there is already a column with that name).
 * Similarly, if there is only a single relation from the parent table to the child table
 * then that relation is named after the child table (except if there is already a column with that name).
 */
  test('createRelationsFromTable creates two relations on table with one FK',
      () {
    final keyedTables = keyBy(tables);
    final relations = createRelationsFromTable(fooTable, keyedTables);

    // Expect two relations
    // one for forward direction
    // and one for backward direction
    expect(
      relations.length,
      2,
      reason: 'Expected two relations on table with one FK',
    );

    // Check forward relation
    final relation = relations['foo']!;
    expect(
      relation.length,
      1,
      reason: 'Expected one relation on table with one outgoing FK',
    );

    final [rel] = relation;
    expect(
      rel,
      const Relation(
        // 'other',
        fromField: 'otherr',
        toField: 'other_id',
        relatedTable: 'other',
        relationName: 'foo_otherrToother',
      ),
      reason: 'Expected relation to be created correctly',
    );

    // Check backward relation
    final backwardRelation = relations['other']!;
    expect(
      backwardRelation.length,
      1,
      reason: 'Expected one relation for table with an incoming FK',
    );

    final [backRel] = backwardRelation;
    expect(
      backRel,
      const Relation(
        //'foo',
        fromField: '',
        toField: '',
        relatedTable: 'foo',
        relationName: 'foo_otherrToother',
      ),
      reason: 'Expected relation to be created correctly',
    );
  });

  /*
 * This test checks that if there is a single relation from the child table to the parent table
 * but the child table has a column named after the parent table, than a unique relation field name is used.
 */
  test(
      'createRelationsFromTable makes long relation field name if child column is named after parent table',
      () {
    // Name the child column after the parent table
    fooTable.columns[1].name = 'other';
    fooTable.fks[0].fkCols[0] = 'other';

    final keyedTables = keyBy(tables);
    final relations = createRelationsFromTable(fooTable, keyedTables);

    // Expect two relations
    // one for forward direction
    // and one for backward direction
    expect(
      relations.length,
      2,
      reason: 'Expected two relations on table with one FK',
    );

    // Check forward relation
    final relation = relations['foo']!;
    expect(
      relation.length,
      1,
      reason: 'Expected one relation on table with one outgoing FK',
    );

    final [rel] = relation;
    expect(
      rel,
      const Relation(
        // 'other_foo_otherToother',
        fromField: 'other',
        toField: 'other_id',
        relatedTable: 'other',
        relationName: 'foo_otherToother',
        // 'one'
      ),
      reason: 'Expected relation to be created correctly',
    );

    // Check backward relation
    final backwardRelation = relations['other']!;
    expect(
      backwardRelation.length,
      1,
      reason: 'Expected one relation for table with an incoming FK',
    );

    final [backRel] = backwardRelation;
    expect(
      backRel,
      const Relation(
        //  'foo',
        fromField: '',
        toField: '',
        relatedTable: 'foo',
        relationName: 'foo_otherToother',
        // 'many',
      ),
      reason: 'Expected relation to be created correctly',
    );
  });

  /*
 * This test checks that if there is a single relation from the child table to the parent table
 * and no relation from the parent table to the child table
 * but the parent table has a column named after the child table,
 * than a unique relation field name is used for the reverse relation.
 */
  test(
      'createRelationsFromTable makes long relation field name if parent column is named after child table',
      () {
    // Name the parent column after the child table
    otherTable.columns[0].name = 'foo';
    otherTable.pks[0] = 'foo';
    fooTable.fks[0].pkCols[0] = 'foo';

    final keyedTables = keyBy(tables);
    final relations = createRelationsFromTable(fooTable, keyedTables);

    // Expect two relations
    // one for forward direction
    // and one for backward direction
    expect(
      relations.length,
      2,
      reason: 'Expected two relations on table with one FK',
    );

    // Check forward relation
    final relation = relations['foo']!;
    expect(
      relation.length,
      1,
      reason: 'Expected one relation on table with one outgoing FK',
    );

    final [rel] = relation;
    expect(
      rel,
      const Relation(
        // 'other',
        fromField: 'otherr',
        toField: 'foo',
        relatedTable: 'other',
        relationName: 'foo_otherrToother',
        // 'one',
      ),
      reason: 'Expected relation to be created correctly',
    );

    // Check backward relation
    final backwardRelation = relations['other']!;
    expect(
      backwardRelation.length,
      1,
      reason: 'Expected one relation for table with an incoming FK',
    );

    final [backRel] = backwardRelation;
    expect(
      backRel,
      const Relation(
        // 'foo_foo_otherrToother',
        fromField: '',
        toField: '',
        relatedTable: 'foo',
        relationName: 'foo_otherrToother',
        // 'many'
      ),
      reason: 'Expected relation to be created correctly',
    );
  });

  /*
 * If there are multiple relations from the child table to the parent table
 * than we need to create unique relation field names for each relation.
 */
  test(
      'createRelationsFromTable makes long relation field name if several FKs are pointing to same parent table',
      () {
    final keyedTables = keyBy(tables);
    final relations = createRelationsFromTable(itemsTable, keyedTables);

    // Check forward relations
    final relation = relations['items']!;
    expect(
      relation.length,
      2,
      reason: 'Expected two relations on table with two outgoing FKs',
    );

    final [rel1, rel2] = relation;
    expect(
      rel1,
      const Relation(
        // 'other_items_other_id1Toother',
        fromField: 'other_id1',
        toField: 'other_id',
        relatedTable: 'other',
        relationName: 'items_other_id1Toother',
        // 'one'
      ),
      reason: 'Expected relation to be created correctly',
    );
    expect(
      rel2,
      const Relation(
        // 'other_items_other_id2Toother',
        fromField: 'other_id2',
        toField: 'other_id',
        relatedTable: 'other',
        relationName: 'items_other_id2Toother',
        // 'one'
      ),
      reason: 'Expected relation to be created correctly',
    );

    // Check backward relations
    final backwardRelation = relations['other']!;
    expect(
      backwardRelation.length,
      2,
      reason: 'Expected two relations for table with an incoming FK',
    );

    final [backRel1, backRel2] = backwardRelation;
    expect(
      backRel1,
      const Relation(
        // 'items_items_other_id1Toother',
        fromField: '',
        toField: '',
        relatedTable: 'items',
        relationName: 'items_other_id1Toother',
        // 'many'
      ),
      reason: 'Expected relation to be created correctly',
    );
    expect(
      backRel2,
      const Relation(
        // 'items_items_other_id2Toother',
        fromField: '',
        toField: '',
        relatedTable: 'items',
        relationName: 'items_other_id2Toother',
        // 'many'
      ),
      reason: 'Expected relation to be created correctly',
    );
  });

  /*
 * If we are creating a relation for a FK pointing from child table to the parent table
 * and the parent table also has a FK from parent to child table
 * then there are 2 possible ways to go from parent to child table
 *   1. Follow the FK from parent to child table
 *   2. Follow the FK from child to parent table in reverse direction
 * To avoid this ambiguity, we introduce unique relation field names
 * This test checks that this case is detected and a unique name is constructed
 */
  test(
      'createRelationsFromTable makes long relation field name if parent table has a FK to the child table',
      () {
    // Extend the parent table `other` with a FK to the child table `foo`
    final fIdColPointingToFoo = SatOpMigrate_Column(
      name: 'f_id',
      sqliteType: 'TEXT',
      pgType: SatOpMigrate_PgColumnType(
        name: 'text',
        array: [],
        size: [],
      ),
    );

    final fk = SatOpMigrate_ForeignKey(
      fkCols: ['f_id'],
      pkTable: 'foo',
      pkCols: ['foo_id'],
    );

    otherTable.columns.add(fIdColPointingToFoo);
    otherTable.fks.add(fk);

    // Generate relations from the FKs of the `foo` table
    final keyedTables = keyBy(tables);
    final relations = createRelationsFromTable(fooTable, keyedTables);

    // Check forward relation
    final relation = relations['foo']!;
    expect(
      relation.length,
      1,
      reason: 'Expected one relation on table with one outgoing FK',
    );

    final [rel] = relation;
    expect(
      rel,
      const Relation(
        // 'other_foo_otherrToother',
        fromField: 'otherr',
        toField: 'other_id',
        relatedTable: 'other',
        relationName: 'foo_otherrToother',
        // 'one'
      ),
      reason: 'Expected relation to be created correctly',
    );

    // Check backward relation
    final backwardRelation = relations['other']!;
    expect(
      backwardRelation.length,
      1,
      reason: 'Expected one relation for table with an incoming FK',
    );

    final [backRel] = backwardRelation;
    expect(
      backRel,
      const Relation(
        // 'foo_foo_otherrToother',
        fromField: '',
        toField: '',
        relatedTable: 'foo',
        relationName: 'foo_otherrToother',
        // 'many'
      ),
      reason: 'Expected relation to be created correctly',
    );
  });

  test('createRelationsFromAllTables aggregates all relations', () {
    final relations = createRelationsFromAllTables(tables);

    expect(relations, {
      'foo': [
        const Relation(
          // 'other',
          fromField: 'otherr',
          toField: 'other_id',
          relatedTable: 'other',
          relationName: 'foo_otherrToother',
          // 'one'
        ),
      ],
      'other': [
        const Relation(
          //'foo',
          fromField: '', toField: '', relatedTable: 'foo',
          relationName: 'foo_otherrToother',
          //'many'
        ),
        const Relation(
          // 'items_items_other_id1Toother',
          fromField: '',
          toField: '',
          relatedTable: 'items',
          relationName: 'items_other_id1Toother',
          // 'many'
        ),
        const Relation(
          // 'items_items_other_id2Toother',
          fromField: '',
          toField: '',
          relatedTable: 'items',
          relationName: 'items_other_id2Toother',
          // 'many'
        ),
      ],
      'items': [
        const Relation(
          // 'other_items_other_id1Toother',
          fromField: 'other_id1',
          toField: 'other_id',
          relatedTable: 'other',
          relationName: 'items_other_id1Toother',
          // 'one'
        ),
        const Relation(
          // 'other_items_other_id2Toother',
          fromField: 'other_id2',
          toField: 'other_id',
          relatedTable: 'other',
          relationName: 'items_other_id2Toother',
          // 'one'
        ),
      ],
    });
  });

  test('createDbDescription creates a DbSchema from tables', () {
    final dbDescription = createDbDescription(tables);
    expect(dbDescription.tableSchemas, <String, TableSchema>{
      'foo': const TableSchema(
        fields: {
          'foo_id': PgType.text,
          'otherr': PgType.text,
        },
        relations: [
          Relation(
            // 'other',
            fromField: 'otherr',
            toField: 'other_id',
            relatedTable: 'other',
            relationName: 'foo_otherrToother',
            // 'one'
          ),
        ],
      ),
      'other': const TableSchema(
        fields: {'other_id': PgType.text},
        relations: [
          Relation(
            //'foo',
            fromField: '', toField: '', relatedTable: 'foo',
            relationName: 'foo_otherrToother',
            //'many'
          ),
          Relation(
            // 'items_items_other_id1Toother',
            fromField: '',
            toField: '',
            relatedTable: 'items',
            relationName: 'items_other_id1Toother',
            // 'many'
          ),
          Relation(
            // 'items_items_other_id2Toother',
            fromField: '',
            toField: '',
            relatedTable: 'items',
            relationName: 'items_other_id2Toother',
            // 'many'
          ),
        ],
      ),
      'items': const TableSchema(
        fields: {
          'items_id': PgType.text,
          'other_id1': PgType.text,
          'other_id2': PgType.text,
        },
        relations: [
          Relation(
            // 'other_items_other_id1Toother',
            fromField: 'other_id1',
            toField: 'other_id',
            relatedTable: 'other',
            relationName: 'items_other_id1Toother',
            // 'one'
          ),
          Relation(
            // 'other_items_other_id2Toother',
            fromField: 'other_id2',
            toField: 'other_id',
            relatedTable: 'other',
            relationName: 'items_other_id2Toother',
            // 'one'
          ),
        ],
      ),
    });
  });
}

KeyedTables keyBy(List<SatOpMigrate_Table> tables) {
  return Map.fromEntries(tables.map((table) => MapEntry(table.name, table)));
}
