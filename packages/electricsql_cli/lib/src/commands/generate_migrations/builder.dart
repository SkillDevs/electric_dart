import 'dart:convert';
import 'dart:io';

import 'package:electricsql/migrators.dart';
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
    migrationFiles.map(readMetadataFile),
  );
  return migrationsMetadatas.map(makeMigration).toList();
}

/// Reads the specified metadata file.
/// @param path Path to the metadata file.
/// @returns A promise that resolves with the metadata.
Future<MetaData> readMetadataFile(File file) async {
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

const _kTab = '  ';

String generateMigrationsDartCode(List<Migration> migrations) {
  final migrationLines =
      migrations.map((m) => '${generateSingleMigrationDartCode(m, _kTab)},');
  final migrationsStr = migrationLines.join('\n');
  return '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: prefer_single_quotes, lines_longer_than_80_chars, avoid_escaping_inner_quotes, depend_on_referenced_packages
import 'package:electricsql/electricsql.dart';

final kElectricMigrations = [
$migrationsStr
];
''';
}

String generateSingleMigrationDartCode(
  Migration migration,
  String indent,
) {
  final stmtIndent = '$indent$_kTab$_kTab';
  final statments = migration.statements.map((stmt) {
    final singleLineStmt = stmt
        .replaceAll('\n', r'\n')
        .replaceAll('"', r'\"')
        .replaceAll('\t', r'\t');
    return '$stmtIndent"$singleLineStmt",';
  });
  final statementsString = statments.join('\n');
  return '''
${indent}Migration(
$indent${_kTab}statements: [
$statementsString
$indent$_kTab],
$indent${_kTab}version: "${migration.version}",
$indent)''';
}
