import 'dart:convert';
import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql_cli/src/commands/generate/builder/enums.dart';
import 'package:electricsql_cli/src/commands/generate/builder/util.dart';
import 'package:electricsql_cli/src/commands/generate/drift_gen_opts.dart';
import 'package:electricsql_cli/src/commands/generate/drift_schema.dart';
import 'package:electricsql_cli/src/drift_gen_util.dart';
import 'package:path/path.dart' as path;

Future<void> buildMigrations(
  Directory migrationsFolder,
  File migrationsFile,
) async {
  final migrations = await loadMigrations(migrationsFolder);

  final outParent = migrationsFile.parent;
  if (!outParent.existsSync()) {
    await outParent.create(recursive: true);
  }

  final contents = generateMigrationsDartCode(migrations);

  // Update the configuration file
  await migrationsFile.writeAsString(contents);
}

Future<List<Migration>> loadMigrations(Directory migrationsFolder) async {
  final migrationDirNames = await getMigrationNames(migrationsFolder);
  final migrationFiles = migrationDirNames.map(
    (dirName) =>
        File(path.join(migrationsFolder.path, dirName, 'metadata.json')),
  );
  final migrationsMetadatas = await Future.wait(
    migrationFiles.map(_readMetadataFile),
  );
  return migrationsMetadatas.map(makeMigration).toList();
}

/// Reads the specified metadata file.
/// @param path Path to the metadata file.
/// @returns A promise that resolves with the metadata.
Future<MetaData> _readMetadataFile(File file) async {
  try {
    final data = await file.readAsString();
    final jsonData = json.decode(data);

    if (jsonData is! Map<String, Object?>) {
      throw Exception(
          'Migration file ${file.path} has wrong format, expected JSON object '
          'but found something else.');
    }

    return parseMetadata(jsonData);
  } catch (e, st) {
    throw Exception(
      'Error while parsing migration file ${file.path}. $e\n$st',
    );
  }
}

/// Reads the provided `migrationsFolder` and returns an array
/// of all the migrations that are present in that folder.
/// Each of those migrations are in their respective folder.
/// @param migrationsFolder
Future<List<String>> getMigrationNames(Directory migrationsFolder) async {
  final dirs = migrationsFolder.listSync().whereType<Directory>();
  // the directory names encode the order of the migrations
  // therefore we sort them by name to get them in chronological order
  final dirNames = dirs.map((dir) => dir.path).toList()..sort();
  return dirNames;
}

String generateMigrationsDartCode(List<Migration> migrations) {
  final migrationReference = refer('Migration', kElectricSqlImport);

  // Migrations
  final List<Expression> migrationExpressions = migrations.map((m) {
    final stmts = m.statements.map((stmt) => literal(stmt)).toList();
    final stmtsList = literalList(stmts);
    return migrationReference.newInstance([], {
      'statements': stmtsList,
      'version': literal(m.version),
    });
  }).toList();

  // UnmodifiableListView<Migration>
  final unmodifListReference = _getUnmodifiedableListRef(migrationReference);

  // global final immutable field for the migrations
  final electricMigrationsField = Field(
    (b) => b
      ..name = 'kElectricMigrations'
      ..modifier = FieldModifier.final$
      ..assignment = unmodifListReference.newInstance([
        literalList(migrationExpressions, migrationReference),
      ]).code,
  );

  return _buildLibCode(
    (b) => b..body.add(electricMigrationsField),
  );
}

TypeReference _getUnmodifiedableListRef(Reference genericRef) {
  return TypeReference(
    (b) => b
      ..url = 'dart:collection'
      ..symbol = 'UnmodifiableListView'
      ..types.add(genericRef.type),
  );
}

String _buildLibCode(void Function(LibraryBuilder b) updateLib) {
  final library = Library(
    (b) {
      b
        ..comments.add('GENERATED CODE - DO NOT MODIFY BY HAND')
        ..ignoreForFile.addAll([
          'depend_on_referenced_packages',
          'prefer_double_quotes',
        ]);
      updateLib(b);
    },
  );

  final emitter = DartEmitter(
    allocator: Allocator(),
    useNullSafetySyntax: true,
    orderDirectives: true,
  );
  final codeStr = DartFormatter().format(
    '${library.accept(emitter)}',
  );
  return codeStr;
}

Future<void> buildDriftSchemaDartFile(
  DriftSchemaInfo driftSchemaInfo,
  File driftSchemaFile,
) async {
  final outParent = driftSchemaFile.parent;
  if (!outParent.existsSync()) {
    await outParent.create(recursive: true);
  }

  final contents = generateDriftSchemaDartCode(driftSchemaInfo);

  // Update the configuration file
  await driftSchemaFile.writeAsString(contents);
}

String generateDriftSchemaDartCode(DriftSchemaInfo driftSchemaInfo) {
  final List<Class> tableClasses = _getTableClasses(driftSchemaInfo);

  final List<Enum> electricEnums = getElectricEnumDeclarations(driftSchemaInfo);

  return _buildLibCode(
    (b) => b
      ..body.addAll(
        [
          _getElectrifiedTablesField(tableClasses),
          ...tableClasses,
          if (electricEnums.isNotEmpty) ...[
            // Enums
            Code('\n// ${'-' * 30} ENUMS ${'-' * 30}\n\n'),
            ...electricEnums,
            getElectricEnumCodecsClass(driftSchemaInfo),
            getElectricEnumTypesClass(driftSchemaInfo),
          ],
        ],
      ),
  );
}

List<Class> _getTableClasses(DriftSchemaInfo driftSchemaInfo) {
  final tableRef = refer('Table', kDriftImport);

  final List<Class> tableClasses = [];
  for (final tableInfo in driftSchemaInfo.tables) {
    final DriftTableGenOpts? tableGenOpts =
        driftSchemaInfo.genOpts?.tableGenOpts(tableInfo.tableName);

    final List<Method> methods = [];

    final Method? primaryKeyGetter = _getPrimaryKeyGetter(tableInfo);
    final Method? tableNameGetter = _getTableNameGetter(tableInfo);

    methods.addAll(
      [
        // Fields
        for (final columnInfo in tableInfo.columns)
          _getColumnFieldGetter(
            driftSchemaInfo,
            tableInfo.tableName,
            columnInfo,
            driftSchemaInfo.genOpts?.columnGenOpts(
              tableInfo.tableName,
              columnInfo.columnName,
            ),
          ),

        if (tableNameGetter != null) tableNameGetter,
        if (primaryKeyGetter != null) primaryKeyGetter,
        _getWithoutRowIdGetter(),
      ],
    );

    final List<Expression> annotations = [];
    if (tableGenOpts != null) {
      annotations.addAll(tableGenOpts.annotations);

      // ignore: deprecated_member_use_from_same_package
      if (tableGenOpts.dataClassName != null) {
        // ignore: deprecated_member_use_from_same_package
        final dataClassNameInfo = tableGenOpts.dataClassName!;
        annotations.add(
          dataClassNameAnnotation(
            dataClassNameInfo.name,
            extending: dataClassNameInfo.extending,
          ),
        );
      }
    }

    final tableClass = Class(
      (b) => b
        ..extend = tableRef
        ..name = tableInfo.dartClassName
        ..methods.addAll(methods)
        ..annotations.addAll(annotations),
    );
    tableClasses.add(tableClass);
  }
  return tableClasses;
}

Field _getElectrifiedTablesField(List<Class> tableClasses) {
  return Field(
    (b) => b
      ..name = 'kElectrifiedTables'
      ..modifier = FieldModifier.constant
      ..assignment =
          // List of table types
          literalList(tableClasses.map((e) => refer(e.name))).code,
  );
}

Method? _getPrimaryKeyGetter(DriftTableInfo tableInfo) {
  final primaryKeyCols = tableInfo.columns.where((c) => c.isPrimaryKey);
  if (primaryKeyCols.isNotEmpty) {
    return Method(
      (b) => b
        ..name = 'primaryKey'
        ..returns = refer('Set<Column<Object>>?', kDriftImport)
        ..type = MethodType.getter
        ..body = literalSet(primaryKeyCols.map((e) => refer(e.dartName))).code
        ..annotations.add(
          const CodeExpression(Code('override')),
        ),
    );
  }
  return null;
}

Method _getColumnFieldGetter(
  DriftSchemaInfo schemaInfo,
  String tableName,
  DriftColumn columnInfo,
  DriftColumnGenOpts? genOpts,
) {
  var columnBuilderExpr = _getInitialColumnBuilder(schemaInfo, columnInfo);

  if (columnInfo.columnName != columnInfo.dartName) {
    columnBuilderExpr = columnBuilderExpr
        .property('named')
        .call([literal(columnInfo.columnName)]);
  }

  if (columnInfo.isNullable) {
    columnBuilderExpr = columnBuilderExpr.property('nullable').call([]);
  }

  // Custom modifiers
  final columnBuilderModifier = genOpts?.columnBuilderModifier;
  if (columnBuilderModifier != null) {
    columnBuilderExpr = columnBuilderModifier(columnBuilderExpr);
  }

  final columnExpr = columnBuilderExpr.call([]);

  return Method(
    (b) => b
      ..name = columnInfo.dartName
      ..type = MethodType.getter
      ..returns = _getOutColumnTypeFromColumnInfo(schemaInfo, columnInfo)
      ..body = columnExpr.code,
  );
}

Method _getWithoutRowIdGetter() {
  return Method(
    (b) => b
      ..name = 'withoutRowId'
      ..returns = refer('bool')
      ..type = MethodType.getter
      ..body = literal(true).code
      ..annotations.add(
        const CodeExpression(Code('override')),
      ),
  );
}

Method? _getTableNameGetter(DriftTableInfo tableInfo) {
  if (tableInfo.dartClassName == tableInfo.tableName) {
    return null;
  }

  return Method(
    (b) => b
      ..name = 'tableName'
      ..returns = refer('String?')
      ..type = MethodType.getter
      ..body = literal(tableInfo.tableName).code
      ..annotations.add(
        const CodeExpression(Code('override')),
      ),
  );
}

Expression _getInitialColumnBuilder(
  DriftSchemaInfo schemaInfo,
  DriftColumn columnInfo,
) {
  switch (columnInfo.type) {
    case DriftElectricColumnType.int2:
      return _customElectricTypeExpr('int2');
    case DriftElectricColumnType.int4:
      return _customElectricTypeExpr('int4');
    case DriftElectricColumnType.int8:
      return _customElectricTypeExpr('int8');
    case DriftElectricColumnType.float4:
      return _customElectricTypeExpr('float4');
    case DriftElectricColumnType.float8:
      return _customElectricTypeExpr('float8');
    case DriftElectricColumnType.string:
      return refer('text', kDriftImport).call([]);
    case DriftElectricColumnType.bool:
      return refer('boolean', kDriftImport).call([]);
    case DriftElectricColumnType.date:
      return _customElectricTypeExpr('date');
    case DriftElectricColumnType.time:
      return _customElectricTypeExpr('time');
    case DriftElectricColumnType.timeTZ:
      return _customElectricTypeExpr('timeTZ');
    case DriftElectricColumnType.timestamp:
      return _customElectricTypeExpr('timestamp');
    case DriftElectricColumnType.timestampTZ:
      return _customElectricTypeExpr('timestampTZ');
    case DriftElectricColumnType.uuid:
      return _customElectricTypeExpr('uuid');
    case DriftElectricColumnType.enumT:
      final driftEnum = schemaInfo.enums[columnInfo.enumPgType!]!;

      // Generates `customType(ElectricEnumTypes.<enum>Type)`
      final enumTypesClass = refer(kElectricEnumTypesClassName);
      return refer('customType', kDriftImport)
          .call([enumTypesClass.property(driftEnum.driftTypeName)]);
    case DriftElectricColumnType.json:
      return _customElectricTypeExpr('json');
    case DriftElectricColumnType.jsonb:
      return _customElectricTypeExpr('jsonb');
    case DriftElectricColumnType.bigint:
      return refer('int64', kDriftImport).call([]);
  }
}

Expression _customElectricTypeExpr(String electricTypeName) {
  final electricTypesClass = refer('ElectricTypes', kElectricSqlDriftImport);
  return refer('customType', kDriftImport)
      .call([electricTypesClass.property(electricTypeName)]);
}

Reference _getOutColumnTypeFromColumnInfo(
  DriftSchemaInfo schemaInfo,
  DriftColumn columnInfo,
) {
  switch (columnInfo.type) {
    case DriftElectricColumnType.int2:
    case DriftElectricColumnType.int4:
    case DriftElectricColumnType.int8:
      return refer('IntColumn', kDriftImport);
    case DriftElectricColumnType.float8:
    case DriftElectricColumnType.float4:
      return refer('RealColumn', kDriftImport);
    case DriftElectricColumnType.uuid:
    case DriftElectricColumnType.string:
      return refer('TextColumn', kDriftImport);
    case DriftElectricColumnType.bool:
      return refer('BoolColumn', kDriftImport);
    case DriftElectricColumnType.date:
    case DriftElectricColumnType.time:
    case DriftElectricColumnType.timeTZ:
    case DriftElectricColumnType.timestamp:
    case DriftElectricColumnType.timestampTZ:
      return refer('Column<DateTime>', kDriftImport);
    case DriftElectricColumnType.enumT:
      final driftEnum = schemaInfo.enums[columnInfo.enumPgType!]!;
      final enumDartType = driftEnum.dartEnumName;
      return refer('Column<$enumDartType>', kDriftImport);
    case DriftElectricColumnType.json:
    case DriftElectricColumnType.jsonb:
      return refer('Column<Object>', kDriftImport);
    case DriftElectricColumnType.bigint:
      return refer('Int64Column', kDriftImport);
  }
}
