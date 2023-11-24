import 'package:electricsql_cli/src/commands/generate/drift_gen_opts.dart';

class DriftSchemaInfo {
  final List<DriftTableInfo> tables;
  final ElectricDriftGenOpts? genOpts;

  DriftSchemaInfo({
    required this.tables,
    required this.genOpts,
  });

  @override
  String toString() => 'DriftSchemaInfo(tables: $tables)';
}

class DriftTableInfo {
  final String tableName;
  final String dartClassName;
  final List<DriftColumn> columns;

  DriftTableInfo({
    required this.tableName,
    required this.dartClassName,
    required this.columns,
  });

  @override
  String toString() =>
      'DriftTableInfo(tableName: $tableName, dartClassName: $dartClassName, columns: $columns)';
}

class DriftColumn {
  final String columnName;
  final String dartName;
  final DriftElectricColumnType type;
  final bool isPrimaryKey;
  final bool isNullable;
  final DriftEnum? enumType;

  DriftColumn({
    required this.columnName,
    required this.dartName,
    required this.type,
    required this.isNullable,
    required this.isPrimaryKey,
    this.enumType,
  });

  @override
  String toString() {
    return 'DriftColumn(columnName: $columnName, dartName: $dartName, type: $type, nullable: $isNullable, isPrimaryKey: $isPrimaryKey)';
  }
}

class DriftEnum {
  final String pgName;
  final List<String> pgValues;
  final String dartEnumName;

  DriftEnum({
    required this.pgName,
    required this.pgValues,
    required this.dartEnumName,
  });

  @override
  String toString() => 'DriftEnum(name: $pgName, pgValues: $pgValues)';
}

enum DriftElectricColumnType {
  int2,
  int4,
  float8,
  string,
  bool,
  date,
  time,
  timeTZ,
  timestamp,
  timestampTZ,
  uuid,
  enumT,
}
