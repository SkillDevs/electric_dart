import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/process.dart';
import 'package:electricsql/src/util/proto.dart';

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

final protocolVersion = getProtocolVersion();

/// Parses the metadata JSON object that accompanies a migration.
/// The main purpose of this function is to
/// decode the array of base64-encoded operations.
MetaData parseMetadata(Map<String, Object?> data) {
  try {
    final dataProtocol = data['protocol_version']! as String;

    if (dataProtocol != protocolVersion) {
      throw Exception(
        'Protocol version mismatch for migration. Expected: $protocolVersion. Got: $dataProtocol',
      );
    }

    final dataFormat = data['format']! as String;
    final dataOps =
        (data['ops']! as List<dynamic>).cast<String>().map(decode).toList();
    final dataVersion = data['version']! as String;

    // Now decode the `SatOpMigrate` operations inside the `ops` array
    final decoded = MetaData(
      format: dataFormat,
      ops: dataOps,
      protocolVersion: dataProtocol,
      version: dataVersion,
    );

    return decoded;
  } catch (e) {
    throw Exception('Failed to parse migration data, due to:\n$e');
  }
}

/// Takes a migration's meta data and returns a migration.
/// The returned migration contains all DDL statements
/// as well as the necessary triggers.
/// `migration` The migration's meta data.
/// @returns The corresponding migration.
Migration makeMigration(MetaData migration) {
  final statements = migration.ops
      .map((op) => op.stmts.map((stmt) => _removeUserIdColumn(stmt.sql)))
      .expand((l) => l);
  final tablesI = migration.ops.map((op) => op.table).toList();
  // remove duplicate tables
  final tables = tablesI.whereIndexed((idx, tbl) {
    return tablesI.indexWhere((t) => t.name == tbl.name) == idx;
  });

  final triggers = tables
      .map(generateTriggersForTable)
      .expand((l) => l)
      .map((stmt) => _cleanUserIdFromTrigger(stmt.sql));

  return Migration(
    statements: [...statements, ...triggers],
    version: migration.version,
  );
}

String _cleanUserIdFromTrigger(String sql) {
  final cleanSql = sql
      .replaceAll("'electric_user_id',", '')
      .replaceAll('new.electric_user_id,', '')
      .replaceAll('old.electric_user_id,', '')
      // Without commas
      .replaceAll("'electric_user_id'", '')
      .replaceAll('new.electric_user_id', '')
      .replaceAll('old.electric_user_id', '');
  return cleanSql;
}

String _removeUserIdColumn(String sql) {
  final cleanSql = sql.replaceAll('"electric_user_id" TEXT NOT NULL,\n  ', '');
  return cleanSql;
}

/// Decodes a base64-encoded `SatOpMigrate` message.
/// @param data String containing the base64-encoded `SatOpMigrate` message.
SatOpMigrate decode(String data) {
  final bytes = base64.decode(data);
  return SatOpMigrate.fromBuffer(bytes);
}
