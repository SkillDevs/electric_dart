import 'package:electric_client/satellite/oplog.dart';

typedef TableInfo = Map<String, TableSchema>;

class TableSchema {
  final List<String> primaryKey;
  final List<String> columns;

  TableSchema({required this.primaryKey, required this.columns});
}

TableInfo initTableInfo() {
  return {
    'main.parent': TableSchema(
      primaryKey: ['id'],
      columns: ['id', 'value', 'other'],
    ),
    'main.child': TableSchema(
      primaryKey: ['id'],
      columns: ['id', 'parent'],
    ),
    'main.items': TableSchema(
      primaryKey: ['value'],
      columns: ['value', 'other'],
    ),
  };
}

String genEncodedTags(
  String origin,
  List<DateTime> dates,
) {
  final tags = dates.map((date) {
    return generateTag(origin, date);
  }).toList();
  return encodeTags(tags);
}
