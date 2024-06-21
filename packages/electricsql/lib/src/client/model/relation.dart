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

  TableInfo<T, dynamic> getDriftTable<DB extends GeneratedDatabase>(DB db) {
    final TableInfo<Table, dynamic> genTable = db.allTables.firstWhere((t) {
      return t is T;
    });
    return genTable as TableInfo<T, dynamic>;
  }
}

abstract interface class TableRelations {
  List<TableRelation<Table>> get $relationsList;
}

TableRelations? getTableRelations<T extends Table>(T table) {
  if (table is! ElectricTableMixin) {
    return null;
  }
  return table.$relations;
}
