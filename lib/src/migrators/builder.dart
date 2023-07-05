import 'package:collection/collection.dart';
import 'package:electric_client/electric_dart.dart';
import 'package:electric_client/src/proto/satellite.pb.dart';
import 'package:electric_client/src/satellite/process.dart';

class MetaData {
  final String format;
  final List<SatOpMigrate> ops;
  final String protocolVersion;
  final String version;

  MetaData({
    required this.format,
    required this.ops,
    required this.protocolVersion,
    required this.version,
  });
}

/// Takes a migration's meta data and returns a migration.
/// The returned migration contains all DDL statements
/// as well as the necessary triggers.
/// `migration` The migration's meta data.
/// @returns The corresponding migration.
Migration makeMigration(MetaData migration) {
  final statements = migration.ops
      .map((op) => op.stmts.map((stmt) => stmt.sql))
      .expand((l) => l);
  final tablesI = migration.ops.map((op) => op.table).toList();
  // remove duplicate tables
  final tables = tablesI.whereIndexed((idx, tbl) {
    return tablesI.indexWhere((t) => t.name == tbl.name) == idx;
  });

  final triggers = tables
      .map(generateTriggersForTable)
      .expand((l) => l)
      .map((stmt) => stmt.sql);

  return Migration(
    statements: [...statements, ...triggers],
    version: migration.version,
  );
}
