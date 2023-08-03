import 'dart:math';

import 'package:electric_client/src/util/types.dart';

// export function isInsertUpdateOrDeleteStatement(sql: string) {
//   const tpe = sql.toLowerCase().trimStart()
//   return (
//     tpe.startsWith('insert') ||
//     tpe.startsWith('update') ||
//     tpe.startsWith('delete')
//   )
// }

/*
 * Prepare multiple batched insert statements for an array of records.
 *
 * Since SQLite only supports a limited amount of positional `?` parameters,
 * we generate multiple insert statements with each one being filled as much
 * as possible from the given data. All statements are derived from same `baseSql` -
 * the positional parameters will be appended to this string.
 *
 * @param baseSql base SQL string to which inserts should be appended
 * @param columns columns that describe records
 * @param records records to be inserted
 * @param maxParameters max parameters this SQLite can accept - determines batching factor
 * @returns array of statements ready to be executed by the adapter
 */

List<Statement> prepareInsertBatchedStatements(
  String baseSql,
  List<String> columns,
  List<Map<String, SqlValue>> records,
  int maxParameters,
) {
  final List<Statement> stmts = [];
  final columnCount = columns.length;
  final recordCount = records.length;
  int processed = 0;
  final insertPattern =
      ' (' + List.generate(columnCount, (_) => '?').join(', ') + '),';

  // Largest number below maxSqlParamers that evenly divides by column count,
  // divided by columnCount, giving the amount of rows we can insert at once
  final batchMaxSize =
      (maxParameters - (maxParameters % columnCount)) ~/ columnCount;
  while (processed < recordCount) {
    final currentInsertCount = min<int>(recordCount - processed, batchMaxSize);
    final _tmp = insertPattern * currentInsertCount;
    final sql = baseSql + _tmp.substring(0, _tmp.length - 1);
    final args = records
        .sublist(processed, processed + currentInsertCount)
        .expand((record) => columns.map((col) => record[col]))
        .toList();

    processed += currentInsertCount;
    stmts.add(Statement(sql, args));
  }
  return stmts;
}
