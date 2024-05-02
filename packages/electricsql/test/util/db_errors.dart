// ignore_for_file: constant_identifier_names

// https://sqlite.org/rescode.html

class SqliteErrors {
  static const SQLITE_CONSTRAINT_PRIMARYKEY = 1555;
  static const SQLITE_CONSTRAINT_TRIGGER = 1811;
  static const SQLITE_CONSTRAINT_FOREIGNKEY = 787;
}

class PostgresErrors {
  static const PG_CONSTRAINT_PRIMARYKEY = '23505';
  static const PG_CONSTRAINT_TRIGGER = 'P0001';
  static const PG_CONSTRAINT_FOREIGNKEY = '23503';
}
