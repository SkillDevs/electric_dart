import 'dart:async';
import 'dart:io';

import 'package:electricsql_cli/src/prisma_schema_parser.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart';
import 'package:recase/recase.dart';

const String _kPrismaVersion = '5.5.2';
const int _kNodeVersion = 20;

const _kPrismaCLIDockerfile = '''
FROM node:$_kNodeVersion-alpine

RUN npm install -g prisma@$_kPrismaVersion

WORKDIR /cli

ENTRYPOINT ["prisma"]
''';

/// Creates a fresh Prisma schema in the provided folder.
/// The Prisma schema is initialised with a generator and a datasource.
Future<File> createPrismaSchema(
  Directory folder, {
  required String proxy,
}) async {
  final prismaDir = Directory(join(folder.path, 'prisma'));
  final prismaSchemaFile = File(join(prismaDir.path, 'schema.prisma'));
  await prismaDir.create(recursive: true);

  // RelationMode = "prisma" is uses so that "array like" foreign key relations
  // are not created in the prisma schema

  final schema = '''
datasource db {
  provider = "postgresql"
  url      = "$proxy"
  relationMode = "prisma"
}
''';

  await prismaSchemaFile.writeAsString(schema);
  return prismaSchemaFile;
}

Future<void> introspectDB(PrismaCLI cli, File prismaSchema) async {
  await cli.runCommand(
    [
      'db',
      'pull',
      '--schema=${basename(prismaSchema.path)}',
    ],
    workingDirectory: prismaSchema.parent.path,
    errorMsg: 'Database introspection failed',
  );
}

class PrismaCLI {
  final Logger logger;
  final Directory folder;

  static const String _imageName = 'electric-dart/prisma-cli';

  PrismaCLI({required this.logger, required this.folder});

  // Build the Prisma CLI Docker image
  Future<void> install() async {
    await _createDockerfile();

    final res = await Process.run(
      'docker',
      [
        'build',
        '-t',
        _imageName,
        '.',
      ],
      workingDirectory: folder.path,
    );

    if (res.exitCode != 0) {
      throw Exception('Could not build Prisma CLI Docker image\n'
          'Exit code: $exitCode\n'
          'Stderr: ${res.stderr}\n'
          'Stdout: ${res.stdout}');
    }
  }

  Future<void> runCommand(
    List<String> args, {
    required String workingDirectory,
    String? errorMsg,
  }) async {
    final res = await Process.run(
      'docker',
      [
        'run',
        '--rm',
        '-v',
        '.:/cli',
        '--network',
        'host',
        _imageName,
        ...args,
      ],
      workingDirectory: workingDirectory,
    );

    //unawaited(stdout.addStream(process.stdout));

    final exitCode = res.exitCode;
    if (exitCode != 0) {
      final baseMsg = errorMsg ?? 'Could not run Prisma CLI with args: $args';
      throw Exception('$baseMsg\n'
          'Exit code: $exitCode\n'
          'Stderr: ${res.stderr}\n'
          'Stdout: ${res.stdout}');
    }
  }

  Future<File> _createDockerfile() async {
    final dockerfile = File(join(folder.path, 'Dockerfile'));
    await dockerfile.writeAsString(_kPrismaCLIDockerfile);
    return dockerfile;
  }
}

DriftSchemaInfo extractInfoFromPrismaSchema(String prismaSchema) {
  final models = parseModels(prismaSchema);
  //print(models);

  final tableInfos = models.map((e) {
    final modelName = e.name;
    String tableName = modelName;

    final mapAttr = e.attributes
        .where(
          (a) => a.type == '@@map',
        )
        .firstOrNull;

    if (mapAttr != null) {
      final mappedNameLiteral = mapAttr.args.join(',');
      tableName = _extractStringLiteral(mappedNameLiteral);
    }
    final className = modelName.pascalCase;

    return DriftTableInfo(
      tableName: tableName,
      dartClassName: className,
      columns: _prismaFieldsToColumns(e, e.fields).toList(),
    );
  }).toList();

  final schemaInfo = DriftSchemaInfo(tables: tableInfos);

  return schemaInfo;
}

String _extractStringLiteral(String s) {
  if (s.startsWith('"') && s.endsWith('"')) {
    return s.substring(1, s.length - 1);
  }

  if (s.startsWith("'") && s.endsWith("'")) {
    return s.substring(1, s.length - 1);
  }

  throw Exception('Expected string literal: $s');
}

Iterable<DriftColumn> _prismaFieldsToColumns(
  Model model,
  List<Field> fields,
) sync* {
  final primaryKeyFields = _getPrimaryKeysFromModel(model);

  for (final field in fields) {
    if (field.type.endsWith('[]')) {
      // No array types
      continue;
    }

    if (field.attributes.any((a) => a.type == '@relation')) {
      // No relations
      continue;
    }

    final fieldName = field.field;
    String columnName = fieldName;

    if (columnName == 'electric_user_id') {
      // Don't include "electric_user_id" special column in the client schema
      continue;
    }

    final mapAttr = field.attributes
        .where(
          (a) => a.type == '@map',
        )
        .firstOrNull;
    if (mapAttr != null) {
      final mappedNameLiteral = mapAttr.args.join(',');
      columnName = _extractStringLiteral(mappedNameLiteral);
    }

    var dartName = fieldName.camelCase;
    if (_isInvalidColumnDartName(dartName)) {
      dartName = '${dartName}Col';
    }

    final bool isPrimaryKey = primaryKeyFields.contains(fieldName);

    yield DriftColumn(
      columnName: columnName,
      dartName: dartName,
      type: _convertPrismaTypeToDrift(field.type, field.attributes),
      isNullable: field.type.endsWith('?'),
      isPrimaryKey: isPrimaryKey,
    );
  }
}

DriftElectricColumnType _convertPrismaTypeToDrift(
  String prismaType,
  List<Attribute> attrs,
) {
  final nonNullableType = prismaType.endsWith('?')
      ? prismaType.substring(0, prismaType.length - 1)
      : prismaType;

  final dbAttr = attrs.where((a) => a.type.startsWith('@db.')).firstOrNull;
  final dbAttrName = dbAttr?.type.substring('@db.'.length);

  switch (nonNullableType) {
    case 'Int':
      if (dbAttrName != null) {
        if (dbAttrName == 'SmallInt') {
          return DriftElectricColumnType.int2;
        }
      }
      return DriftElectricColumnType.int4;
    case 'Float':
      return DriftElectricColumnType.float8;
    case 'String':
      if (dbAttrName != null) {
        if (dbAttrName == 'Uuid') {
          return DriftElectricColumnType.uuid;
        }
      }
      return DriftElectricColumnType.string;
    case 'Boolean':
      return DriftElectricColumnType.bool;
    case 'DateTime':
      // Expect to have a db. attribute with a PG type
      if (dbAttr == null) {
        throw Exception('Expected DateTime field to have a @db. attribute');
      }
      final dbAttrName = dbAttr.type.substring('@db.'.length);
      switch (dbAttrName) {
        case 'Date':
          return DriftElectricColumnType.date;
        case 'Time':
          return DriftElectricColumnType.time;
        case 'Timetz':
          return DriftElectricColumnType.timeTZ;
        case 'Timestamp':
          return DriftElectricColumnType.timestamp;
        case 'Timestamptz':
          return DriftElectricColumnType.timestampTZ;
        default:
          throw Exception('Unknown DateTime @db. attribute: $dbAttrName');
      }
    default:
      throw Exception('Unknown Prisma type: $nonNullableType');
  }
}

Set<String> _getPrimaryKeysFromModel(Model m) {
  final idFields =
      m.fields.where((f) => f.attributes.any((a) => a.type == '@id'));
  final Set<String> idFieldsSet = idFields.map((f) => f.field).toSet();

  final Attribute? modelIdAttr =
      m.attributes.where((a) => a.type == '@@id').firstOrNull;

  if (modelIdAttr == null) {
    return idFieldsSet;
  }

  final modelIdAttrArgs = modelIdAttr.args.join(',').trim();
  assert(
    modelIdAttrArgs.startsWith('[') && modelIdAttrArgs.endsWith(']'),
    'Expected @@id to have arguments in the form of [field1, field2, ...]',
  );

  final compositeFields = modelIdAttrArgs
      .substring(1, modelIdAttrArgs.length - 1)
      .split(',')
      .map((s) => s.trim())
      .toSet();

  return compositeFields.toSet()..addAll(idFieldsSet);
}

class DriftSchemaInfo {
  final List<DriftTableInfo> tables;

  DriftSchemaInfo({
    required this.tables,
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

  DriftColumn({
    required this.columnName,
    required this.dartName,
    required this.type,
    required this.isNullable,
    required this.isPrimaryKey,
  });

  @override
  String toString() {
    return 'DriftColumn(columnName: $columnName, dartName: $dartName, type: $type, nullable: $isNullable, isPrimaryKey: $isPrimaryKey)';
  }
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
}

bool _isInvalidColumnDartName(String name) {
  return const [
    // dart primitive types
    'int',
    'bool',
    'double',
    'null',
    // drift table getters
    'tableName',
    'withoutRowId',
    'dontWriteConstraints',
    'isStrict',
    'primaryKey',
    'uniqueKeys',
    'customConstraints',
    'integer',
    'int64',
    'intEnum',
    'text',
    'textEnum',
    'boolean',
    'dateTime',
    'blob',
    'real',
    'customType',
  ].contains(name);
}
