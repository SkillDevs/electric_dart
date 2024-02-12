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

/// Read an enum value from the database as a String.
/// Enums need to be treated differently because we don't have the oid for them,
/// so we use the string representation and decode it when reading the value.
String readEnum(Object sqlValue) {
  throw UnsupportedError('Needs to be run in a dart:io environment.');
}
