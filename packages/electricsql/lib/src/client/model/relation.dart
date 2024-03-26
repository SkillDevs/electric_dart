import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:electricsql/src/client/model/schema.dart';

class TableRelation<T extends Table> {
  final String fromField;
  final String toField;
  final String relationName;

  const TableRelation({
    required this.fromField,
    required this.toField,
    required this.relationName,
  });

  bool isIncomingRelation() {
    return fromField == '' && toField == '';
  }

  bool isOutgoingRelation() {
    return !isIncomingRelation();
  }

  T getDriftTable<DB extends GeneratedDatabase>(DB db) {
    final TableInfo<Table, dynamic> genTable = db.allTables.firstWhere((t) {
      return t is T;
    });
    return genTable as T;
  }

  TableRelation<Table> getOppositeRelation(GeneratedDatabase db) {
    final relatedTable = getDriftTable(db);

    Never throwError() => throw Exception(
          'Unexpected state: Table does not have an opposite relation',
        );

    if (relatedTable is! ElectricTableMixin) {
      throwError();
    }

    final TableRelations? relations = relatedTable.$relations;

    if (relations == null) {
      throwError();
    }

    final oppositeRelation = relations.$relationsList
        .firstWhereOrNull((rel) => relationName == rel.relationName);

    if (oppositeRelation == null) {
      throwError();
    }

    return oppositeRelation;
  }
}

abstract interface class TableRelations {
  List<TableRelation<Table>> get $relationsList;
}
