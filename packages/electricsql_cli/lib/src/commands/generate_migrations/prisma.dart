import 'dart:async';
import 'dart:io';

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

// TODO(dart): maybe remove
Future<void> extractInfoFromPrismaSchema(String prismaSchema) async {
  final models = parseModels(prismaSchema);

  print(models);

  final tableInfos = models.map((e) {
    final tableName = e.name;
    final className = tableName.pascalCase;

    print("$tableName -> $className");

    return DriftTableInfo(
      tableName: tableName,
      dartClassName: className,
      columns: e.fields.map((e) => _prismaFieldToColumn(e)).toList(),
    );
  }).toList();

  final schemaInfo = DriftSchemaInfo(tables: tableInfos);

  print(schemaInfo);
}

DriftColumn _prismaFieldToColumn(Field field) {
  final columnName = field.field;
  final dartName = columnName.camelCase;

  final bool isPrimaryKey = field.attributes.any((a) => a.type == '@id');

  return DriftColumn(
    columnName: columnName,
    dartName: dartName,
    type: DriftElectricColumnType.date,
    isPrimaryKey: isPrimaryKey,
  );
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

  DriftTableInfo(
      {required this.tableName,
      required this.dartClassName,
      required this.columns});

  @override
  String toString() =>
      'DriftTableInfo(tableName: $tableName, dartClassName: $dartClassName, columns: $columns)';
}

class DriftColumn {
  final String columnName;
  final String dartName;
  final DriftElectricColumnType type;
  final bool isPrimaryKey;

  DriftColumn({
    required this.columnName,
    required this.dartName,
    required this.type,
    required this.isPrimaryKey,
  });

  @override
  String toString() {
    return 'DriftColumn(columnName: $columnName, dartName: $dartName, type: $type, isPrimaryKey: $isPrimaryKey)';
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

/// Parses the Prisma schema and returns all models.
/// @param prismaSchema The Prisma schema to parse
/// @returns Array of models.
List<Model> parseModels(String prismaSchema) {
  // Remove comments
  // matches // until end of the line (also matches field validators added with ///)
  final commentRegex = RegExp(r'\/\/.*$', multiLine: true);
  final schema = prismaSchema.replaceAll(commentRegex, '');

  // Match models defined in the schema
  final modelRegex =
      RegExp(r'^\s*model\s+(?<name>\w+)\s*{(?<body>[^}]*)}', multiLine: true);
  final matches = [...modelRegex.allMatches(schema)];
  final modelBodies = matches.map((match) {
    final name = match.namedGroup('name')!.trim();
    final body = match.namedGroup('body')!;

    return (
      name: name,
      body: body,
    );
  });

  // // Match fields in the body of the models
  return modelBodies
      .map((model) => Model(name: model.name, fields: parseFields(model.body)))
      .toList();
}

/// Takes the body of a model and returns
/// an array of fields defined by the model.
/// @param body Body of a model
/// @returns Fields defined by the model
List<Field> parseFields(String body) {
  // The regex below matches the fields of a model (it assumes there are no comments at the end of the line)
  // It uses named captured groups to capture the field name, its type, and optional attributes
  // the type can be `type` or `type?` or `type[]`
  final fieldRegex = RegExp(
    r'^\s*(?<field>\w+)\s+(?<type>[\w]+(\?|(\[]))?)\s*(?<attributes>((@[\w.]+\s*)|(@[\w.]+\(.*\)+\s*))+)?\s*$',
    multiLine: true,
  );
  final fieldMatches = [...fieldRegex.allMatches(body)];
  final fs = fieldMatches.map((match) {
    final field = match.namedGroup('field')!.trim();
    final type = match.namedGroup('type')!.trim();
    final String? attributes = match.namedGroup('attributes');

    return (
      field: field,
      type: type,
      attributes: attributes,
    );
  });

  return fs.map((f) {
    return Field(
      field: f.field,
      type: f.type,
      attributes: parseAttributes(f.attributes),
    );
  }).toList();
}

/// Takes a string of attributes, e.g. `@id @db.Timestamp(2)`,
/// and returns an array of attributes, e.g. `['@id', '@db.Timestamp(2)]`.
/// @param attributes String of attributes
/// @returns Array of attributes.
List<Attribute> parseAttributes(String? attributes) {
  if (attributes == null) return [];

  // Matches each attribute in a string of attributes
  // e.g. @id @db.Timestamp(2)
  // The optional args capture group matches anything
  // but not @or newline because that would be the start of a new attribute
  final attributeRegex = RegExp(r'(?<type>@[\w\.]+)(?<args>\([^@\n\r]+\))?');
  final matches = [...attributeRegex.allMatches(attributes)];
  return matches.map((m) {
    final type = m.namedGroup('type')!;
    final String? args = m.namedGroup('args');

    final noParens = args?.substring(
        1, args.length - 1); // arguments without starting '(' and closing ')'
    final parsedArgs =
        noParens?.split(',').map((arg) => arg.trim()).toList() ?? [];

    assert(
        type.startsWith('@'), 'The attribute type is expected to start with @');
    return Attribute(
      type: type,
      args: parsedArgs,
    );
  }).toList();
}

class Attribute {
  // With the format @{string}
  final String type;
  final List<String> args;

  Attribute({required this.type, required this.args});

  @override
  String toString() {
    return 'Attribute(type: $type, args: $args)';
  }
}

class Field {
  final String field;
  final String type;
  final List<Attribute> attributes;

  Field({required this.field, required this.type, required this.attributes});

  @override
  String toString() {
    return 'Field(field: $field, type: $type, attributes: $attributes)';
  }
}

class Model {
  final String name;
  final List<Field> fields;

  Model({required this.name, required this.fields});

  @override
  String toString() {
    return 'Model(name: $name, fields: $fields)';
  }
}
