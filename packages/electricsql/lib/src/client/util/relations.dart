import 'package:collection/collection.dart';
import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';

Relation makeRelation(
  SatOpMigrate_Table table,
  SatOpMigrate_ForeignKey fk,
  Map<String, List<SatOpMigrate_ForeignKey>> groupedFks,
  KeyedTables allTables,
) {
  final childTable = table.name;
  final childCols = fk.fkCols;
  final parentCols = fk.pkCols;
  final parentTable = fk.pkTable;

  if (childCols.length > 1 || parentCols.length > 1) {
    throw Exception('Composite foreign keys are not supported');
  }

  final childCol = childCols[0];
  final parentCol = parentCols[0];

  // If there is only a single foreign key to a certain parent table
  // and there is no column that is named after the parent table
  // and there is no FK from the parent table to the child table
  // then we can name the relation field the same as the parent table name
  // otherwise the relation field name is the relation name prefixed with the name of the related table
  final noColNamedAfterParent = table.columns.every(
    (col) => col.name != parentTable,
  );
  final singleFk = groupedFks[parentTable]!.length == 1;
  final fkFromParentToChild = allTables[parentTable]!
      .fks
      .firstWhereOrNull((fk) => fk.pkTable == childTable);

  final relationName = '${childTable}_${childCol}To$parentTable';
  // ignore: unused_local_variable
  final relationFieldName =
      singleFk && noColNamedAfterParent && fkFromParentToChild != null
          ? parentTable
          : '${parentTable}_$relationName';

  return Relation(
    // relationFieldName,
    fromField: childCol,
    toField: parentCol,
    relatedTable: parentTable,
    relationName: relationName,
  );
}

typedef GroupedRelations = Map<TableName, List<Relation>>;
typedef KeyedTables = Map<TableName, SatOpMigrate_Table>;

/// Creates a `Relation` object for each FK in the table,
/// as well as the opposite `Relation` object in order to
/// be able to traverse the relation in the opposite direction.
/// As a result, this function returns a map of relations grouped by table name.
GroupedRelations createRelationsFromTable(
  SatOpMigrate_Table table,
  KeyedTables allTables,
) {
  final childTable = table.name;
  final fks = table.fks;
  final groupedFks = groupBy(fks, (fk) => fk.pkTable);

  final GroupedRelations groupedRelations = {};
  void extendGroupedRelations(TableName tableName, Relation relation) {
    final relations = groupedRelations[tableName] ?? [];
    relations.add(relation);
    groupedRelations[tableName] = relations;
  }

  // For each FK make a `Relation`
  final forwardRelations = fks.map((fk) {
    final rel = makeRelation(table, fk, groupedFks, allTables);
    // Store the relation in the `groupedRelations` map
    extendGroupedRelations(childTable, rel);
    return rel;
  });

  // For each FK, also create the opposite `Relation`
  // in order to be able to follow the relation in both directions
  for (final relation in forwardRelations) {
    final parentTableName = relation.relatedTable;
    final parentTable = allTables[parentTableName]!;
    final parentFks = parentTable.fks;
    // If the parent table also has a FK to the child table
    // than there is ambuigity because we can follow this FK
    // or we could follow the FK that points to this table in the opposite direction
    final fkToChildTable = parentFks.firstWhereOrNull(
      (fk) =>
          fk.pkTable == childTable &&
          fk.fkCols[0] !=
              relation
                  .toField, // checks if this is another FK to the same table, assuming no composite FKs
    );
    // Also check if there are others FKs from the child table to this table
    final childFks = allTables[childTable]!.fks;
    final otherFksToParentTable = childFks.firstWhereOrNull(
      (fk) =>
          fk.pkTable == parentTableName &&
          fk.fkCols[0] !=
              relation
                  .fromField, // checks if this is another FK from the child table to this table, assuming no composite FKs
    );
    final noColNamedAfterParent =
        parentTable.columns.every((col) => col.name != childTable);

    // Make the relation field name
    // which is the name of the related table (if it is unique)
    // otherwise it is the relation name prefixed with the name of the related table
    // ignore: unused_local_variable
    final relationFieldName = fkToChildTable != null &&
            otherFksToParentTable != null &&
            noColNamedAfterParent
        ? childTable
        : '${childTable}_${relation.relationName}';

    final backwardRelation = Relation(
      // relationFieldName,
      fromField: '',
      toField: '',
      relatedTable: childTable,
      relationName: relation.relationName,
    );

    // Store the backward relation in the `groupedRelations` map
    extendGroupedRelations(parentTableName, backwardRelation);
  }
  return groupedRelations;
}

void mergeGroupedRelations(
  GroupedRelations groupedRelations,
  GroupedRelations relations,
) {
  for (final entry in relations.entries) {
    final relations = entry.value;
    final tableName = entry.key;
    final existingRelations = groupedRelations[tableName] ?? [];
    groupedRelations[tableName] = [...existingRelations, ...relations];
  }
}

GroupedRelations createRelationsFromAllTables(List<SatOpMigrate_Table> tables) {
  final KeyedTables keyedTables =
      Map.fromEntries(tables.map((table) => MapEntry(table.name, table)));
  final GroupedRelations groupedRelations = {};
  for (final table in tables) {
    final relations = createRelationsFromTable(table, keyedTables);
    mergeGroupedRelations(groupedRelations, relations);
  }
  return groupedRelations;
}

// // TODO: remove the DbSchema type from the DAL and use this one instead
DBSchema createDbDescription(List<SatOpMigrate_Table> tables) {
  final relations = createRelationsFromAllTables(tables);
  final tableSchemas = <String, TableSchema>{};
  for (final table in tables) {
    final tableName = table.name;
    final rels = relations[tableName] ?? [];
    final Fields fields = {};
    for (final col in table.columns) {
      final pgType = maybePgTypeFromColumnType(col.pgType.name);
      // Return text if the pgType is null AKA is an enum
      fields[col.name] = pgType ?? PgType.text;
    }

    tableSchemas[tableName] = TableSchema(
      fields: fields,
      relations: rels,
    );
  }
  return DBSchemaRaw(
    tableSchemas: tableSchemas,
    migrations: [],
    pgMigrations: [],
  );
}
