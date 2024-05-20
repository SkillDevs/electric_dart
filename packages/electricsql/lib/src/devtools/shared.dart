import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/model/shapes.dart';

typedef UnsubscribeFunction = void Function();

class DebugShape {
  final String key;
  final Shape shape;
  final SyncStatusType status;

  DebugShape({
    required this.key,
    required this.shape,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'key': key,
      'shape': shape.toMap(),
      'status': status.index,
    };
  }

  factory DebugShape.fromMap(Map<String, dynamic> map) {
    return DebugShape(
      key: map['key'] as String,
      shape: Shape.fromMap(map['shape'] as Map<String, dynamic>),
      status: SyncStatusType.values[map['status'] as int],
    );
  }
}

class TableColumn {
  final String name;
  final String type;
  final bool nullable;

  TableColumn({
    required this.name,
    required this.type,
    required this.nullable,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'type': type,
      'nullable': nullable,
    };
  }

  factory TableColumn.fromMap(Map<String, dynamic> map) {
    return TableColumn(
      name: map['name'] as String,
      type: map['type'] as String,
      nullable: map['nullable'] as bool,
    );
  }
}

class DbTableInfo {
  final String name;
  final String? sql;
  final List<TableColumn> columns;

  DbTableInfo({
    required this.name,
    required this.sql,
    required this.columns,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'sql': sql,
      'columns': columns.map((x) => x.toMap()).toList(),
    };
  }

  factory DbTableInfo.fromMap(Map<String, dynamic> map) {
    return DbTableInfo(
      name: map['name'] as String,
      sql: map['sql'] as String?,
      columns: List<TableColumn>.from(
        (map['columns'] as List<dynamic>).map<TableColumn>(
          (x) => TableColumn.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
