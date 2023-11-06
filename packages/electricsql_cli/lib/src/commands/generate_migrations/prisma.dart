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
DriftSchemaInfo extractInfoFromPrismaSchema(String prismaSchema) {
  final models = parseModels(prismaSchema);

  print(models);

  final tableInfos = models.map((e) {
    String tableName = e.name;

    final mapAttr = e.attributes
        .where(
          (a) => a.type == '@@map',
        )
        .firstOrNull;

    if (mapAttr != null) {
      final mappedNameLiteral = mapAttr.args.join(',');
      tableName = _extractStringLiteral(mappedNameLiteral);
    }

    final className = e.name.pascalCase;

    print("$tableName -> $className");

    return DriftTableInfo(
      tableName: tableName,
      dartClassName: className,
      columns: _prismaFieldsToColumns(e, e.fields).toList(),
    );
  }).toList();

  final schemaInfo = DriftSchemaInfo(tables: tableInfos);

  print(schemaInfo);

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
    Model model, List<Field> fields) sync* {
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
    final columnName = fieldName;
    final dartName = columnName.camelCase;

    final bool isPrimaryKey = primaryKeyFields.contains(fieldName);

    yield DriftColumn(
      columnName: columnName,
      dartName: dartName,
      type: DriftElectricColumnType.date,
      isPrimaryKey: isPrimaryKey,
    );
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
      .map(
        (model) => Model(
          name: model.name,
          fields: parseFields(model.body),
          attributes: _parseModelAttributes(model.body),
        ),
      )
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
      attributes:
          _parseAttributes(f.attributes, attrType: _AttributeType.field),
    );
  }).toList();
}

List<Attribute> _parseModelAttributes(String body) {
  final attrsRegex = RegExp(
    r'^\s*(?<attribute>(@@[\w.]+\(.*\)+\s*))\s*$',
    multiLine: true,
  );
  final modelAttrsMatches = [...attrsRegex.allMatches(body)];
  final attrs = modelAttrsMatches.map((match) {
    final String attribute = match.namedGroup('attribute')!;

    final parsed = _parseAttributes(attribute, attrType: _AttributeType.model);
    assert(parsed.length == 1, 'Expected exactly @@ attribute');
    return parsed[0];
  }).toList();

  return attrs;
}

enum _AttributeType {
  field,
  model,
}

/// Takes a string of attributes, e.g. `@id @db.Timestamp(2)`,
/// and returns an array of attributes, e.g. `['@id', '@db.Timestamp(2)]`.
/// @param attributes String of attributes
/// @returns Array of attributes.
List<Attribute> _parseAttributes(
  String? attributes, {
  required _AttributeType attrType,
}) {
  if (attributes == null) return [];

  final prefix = switch (attrType) {
    _AttributeType.field => '@',
    _AttributeType.model => '@@',
  };

  // Matches each attribute in a string of attributes
  // e.g. @id @db.Timestamp(2)
  // The optional args capture group matches anything
  // but not @or newline because that would be the start of a new attribute
  final attributeRegex = RegExp(
    // ignore: unnecessary_raw_strings
    r'(?<type>' + prefix + r'[\w\.]+)(?<args>\([^@\n\r]+\))?',
  );
  final matches = [...attributeRegex.allMatches(attributes)];
  return matches.map((m) {
    final type = m.namedGroup('type')!.trim();
    final String? args = m.namedGroup('args');

    List<String> parsedArgs = [];
    if (args != null && args.length > 2) {
      final noParens = args.substring(
        1,
        args.length - 1,
      ); // arguments without starting '(' and closing ')'
      parsedArgs = noParens.split(',').map((arg) => arg.trim()).toList();
    }

    assert(
      type.startsWith(prefix),
      'The attribute type is expected to start with $prefix',
    );
    return Attribute(
      type: type,
      args: parsedArgs,
    );
  }).toList();
}

class Attribute {
  // With the format @{string} or @@{string} if it is a model attribute
  final String type;
  final List<String> args;

  Attribute({required this.type, required this.args});

  @override
  String toString() {
    return "Attribute(type: '$type', args: ${args.map((s) => "'$s'").toList()})";
  }
}

class Field {
  final String field;
  final String type;
  final List<Attribute> attributes;

  Field({required this.field, required this.type, required this.attributes});

  @override
  String toString() {
    return "Field(field: '$field', type: '$type', attributes: $attributes)";
  }
}

class Model {
  final String name;
  final List<Field> fields;
  final List<Attribute> attributes;

  Model({
    required this.name,
    required this.fields,
    required this.attributes,
  });

  @override
  String toString() {
    return 'Model(name: $name, fields: $fields, attributes: $attributes)';
  }
}
