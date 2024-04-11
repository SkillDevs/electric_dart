import 'dart:convert';

import 'package:electricsql/src/client/conversions/types.dart';

/// Map the [dartValue] into a value understood by drift's postgres driver.
///
/// This function is only called when the runtime dialect indicates that we're
/// talking to a postgres database. It is moved into a separate file because the
/// postgres model comes from the `postgres` package, which can only be compiled
/// on native platforms. If `dart:io` is available, this method is replaced by
/// the definition from `postgres_mapping.dart`.
Object mapToSql(PgType? type, Object dartValue) {
  return dartValue;
}

/// Map the [dartValue] into a SQL literal understood by postgres.
String mapToSqlLiteral(
  PgType type,
  Object dartValue,
  String typeName,
  Codec<Object, Object> codec,
) {
  throw UnsupportedError('Needs to be run in a dart:io environment.');
}

/// Map the [sqlValue] into the Dart value used by the Drift schema.
Object mapToUser(PgType? type, Object sqlValue, Codec<Object, Object> codec) {
  throw UnsupportedError('Needs to be run in a dart:io environment.');
}
