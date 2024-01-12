import 'package:electricsql_cli/src/commands/generate/drift_gen_opts.dart';

class DriftSchemaInfo {
  final List<DriftTableInfo> tables;
  final Map<String, DriftEnum> enums;
  final ElectricDriftGenOpts? genOpts;

  DriftSchemaInfo({
    required this.tables,
    required this.enums,
    required this.genOpts,
  });

  @override
  String toString() => 'DriftSchemaInfo(tables: $tables, enums: $enums)';
}

class DriftTableInfo {
  /// The name of the table in the database
  final String tableName;

  /// The name of the Dart Table class in the Drift schema
  final String dartClassName;

  /// Information for the columns
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
  final String? enumPgType;

  DriftColumn({
    required this.columnName,
    required this.dartName,
    required this.type,
    required this.isNullable,
    required this.isPrimaryKey,
    this.enumPgType,
  });

  @override
  String toString() {
    return 'DriftColumn(columnName: $columnName, dartName: $dartName, type: $type, nullable: $isNullable, isPrimaryKey: $isPrimaryKey)';
  }
}

class DriftEnum {
  final String pgName;
  final List<({String dartVal, String pgVal})> values;
  final String dartEnumName;
  final String enumCodecName;
  final String driftTypeName;

  DriftEnum({
    required this.pgName,
    required this.values,
    required this.dartEnumName,
    required this.enumCodecName,
    required this.driftTypeName,
  });

  @override
  String toString() =>
      'DriftEnum(name: $pgName, values: $values, dartEnumName: $dartEnumName, enumCodecName: $enumCodecName, driftTypeName: $driftTypeName)';
}

enum DriftElectricColumnType {
  int2,
  int4,
  int8,
  float4,
  float8,
  string,
  bool,
  date,
  time,
  timeTZ,
  timestamp,
  timestampTZ,
  uuid,
  json,
  jsonb,
  bigint,
  enumT,
}
