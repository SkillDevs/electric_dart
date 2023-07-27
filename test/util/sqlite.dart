import 'package:sqlite3/sqlite3.dart';

// Disable allowing double quotes as literals to ensure that Electric doesn't use them
// Some clients may use a SQlite with the flag DQS=0 which doesn't allow double
// quotes https://www.sqlite.org/compile.html#dqs
void setupSqliteDb(Database db) {
  db.configDoubleQuotedStringLiterals(enable: false);
}
