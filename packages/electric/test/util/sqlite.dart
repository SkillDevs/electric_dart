import 'package:sqlite3/sqlite3.dart';

// Custom open function that disables double quoted string literals
// to ensure that Electric doesn't use them.
// Some clients may use a SQlite with the flag DQS=0 which doesn't allow double
// quotes https://www.sqlite.org/compile.html#dqs
Database openSqliteDb(String path) {
  final db = sqlite3.open(path);
  db.config.doubleQuotedStringLiterals = false;
  return db;
}
