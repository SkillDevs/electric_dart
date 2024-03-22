import 'package:drift/drift.dart';

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
}
