import 'package:electricsql/drivers/sqlite3.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/util/encoders/encoders.dart';
import 'package:test/test.dart';

import '../../util/sqlite.dart';
import '../common.dart';
import '../serialization.dart';

void main() {
  serializationTests(
    dialect: Dialect.sqlite,
    typeEncoder: kSqliteTypeEncoder,
    typeDecoder: kSqliteTypeDecoder,
    setup: () async {
      final db = openSqliteDbMemory();
      addTearDown(() => db.dispose());
      const namespace = 'main';
      final adapter = SqliteAdapter(db);
      return [adapter, kSqliteQueryBuilder, opts(namespace)];
    },
  );
}
