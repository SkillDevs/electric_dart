import 'package:drift/native.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:test/test.dart';

Object? isADbExceptionWithCode(
  Dialect dialect,
  int? sqliteCode,
  Object? pgCode,
) {
  if (dialect == Dialect.sqlite) {
    return isA<SqliteException>().having(
      (SqliteException e) => e.extendedResultCode,
      'code',
      sqliteCode,
    );
  } else {
    return isA<pg.ServerException>().having(
      (pg.ServerException e) => e.code,
      'code',
      pgCode,
    );
  }
}
