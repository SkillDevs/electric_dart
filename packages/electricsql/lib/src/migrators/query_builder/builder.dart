import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/util/index.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart';

enum Dialect {
  sqlite,
  postgres;

  String get name => switch (this) {
        Dialect.sqlite => 'SQLite',
        Dialect.postgres => 'PostgreSQL',
      };
}

enum SqlOpType {
  insert('INSERT'),
  update('UPDATE'),
  delete('DELETE');

  final String text;

  const SqlOpType(this.text);
}

abstract interface class QueryBuilder {
  const QueryBuilder();

  abstract final Dialect dialect;
  abstract final String paramSign; // '?' | '$'
  abstract final String defaultNamespace; // 'main' | 'public'

  /// The autoincrementing integer primary key type for the current SQL dialect.
  abstract final String autoincrementPkType;

  /// The type to use for BLOB for the current SQL dialect.
  abstract final String blobType;

  /// Defers foreign key checks for the current transaction.
  abstract final String deferForeignKeys;

  /// Queries the version of SQLite/Postgres we are using.
  abstract final String getVersion;

  /// Disables foreign key checks.
  abstract final String disableForeignKeys;

  /// Returns the given query if the current SQL dialect is PostgreSQL.
  String pgOnly(String query);

  /// Returns an array containing the given query if the current SQL dialect is PostgreSQL.
  List<String> pgOnlyQuery(String query);

  /// Returns the given query if the current SQL dialect is SQLite.
  String sqliteOnly(String query);

  /// Returns an array containing the given query if the current SQL dialect is SQLite.
  List<String> sqliteOnlyQuery(String query);

  /// Makes the i-th positional parameter,
  /// e.g. '$3' For Postgres when `i` is 3
  ///      and always '?' for SQLite
  String makePositionalParam(int i);

  /// Checks if the given table exists.
  Statement tableExists(String tableName, String? namespace);

  /// Counts tables whose name is included in `tables`.
  /// The count is returned as `countName`.
  Statement countTablesIn(String countName, List<String> tables);

  /// Converts a column value to a hexidecimal string.
  String toHex(String column);

  /// Converts a hexidecimal string to a hex value.
  String hexValue(String hexString);

  /// Create an index on a table.
  String createIndex(
    String indexName,
    QualifiedTablename onTable,
    List<String> columns,
  );

  /// Fetches the names of all tables that are not in `notIn`.
  Statement getLocalTableNames(List<String>? notIn);

  /// Fetches information about the columns of a table.
  /// The information includes all column names, their type,
  /// whether or not they are nullable, and whether they are part of the PK.
  Statement getTableInfo(String tablename);

  /// Insert a row into a table, ignoring it if it already exists.
  Statement insertOrIgnore(
    String table,
    List<String> columns,
    List<Object?> values,
    String? schema,
  );

  /// Insert a row into a table, replacing it if it already exists.
  Statement insertOrReplace(
    String table,
    List<String> columns,
    List<Object?> values,
    List<String> conflictCols,
    List<String> updateCols,
    String? schema,
  );

  /// Insert a row into a table.
  /// If it already exists we update the provided columns `updateCols`
  /// with the provided values `updateVals`
  Statement insertOrReplaceWith(
      String table,
      List<String> columns,
      List<Object?> values,
      List<String> conflictCols,
      List<String> updateCols,
      List<Object?> updateVals,
      String? schema);

  /// Inserts a batch of rows into a table, replacing them if they already exist.
  List<Statement> batchedInsertOrReplace(
    String table,
    List<String> columns,
    List<Map<String, Object?>> records,
    List<String> conflictCols,
    List<String> updateCols,
    int maxSqlParameters,
    String? schema,
  );

  /// Drop a trigger if it exists.
  String dropTriggerIfExists(
    String triggerName,
    String tablename,
    String? namespace,
  );

  /// Create a trigger that prevents updates to the primary key.
  List<String> createNoFkUpdateTrigger(
    String tablename,
    List<String> pk,
    String? namespace,
  );

  /// Creates or replaces a trigger that prevents updates to the primary key.
  List<String> createOrReplaceNoFkUpdateTrigger(
    String tablename,
    List<String> pk,
    String? namespace,
  ) {
    return [
      dropTriggerIfExists(
        'update_ensure_${namespace}_${tablename}_primarykey',
        tablename,
        namespace,
      ),
      ...createNoFkUpdateTrigger(tablename, pk, namespace),
    ];
  }

  /// Modifies the trigger setting for the table identified by its tablename and namespace.
  String setTriggerSetting(String tableName, bool value, String? namespace);

  /// Create a trigger that logs operations into the oplog.
  List<String> createOplogTrigger(
    SqlOpType opType,
    String tableName,
    String newPKs,
    String newRows,
    String oldRows,
    String? namespace,
  );

  List<String> createOrReplaceOplogTrigger(
    SqlOpType opType,
    String tableName,
    String newPKs,
    String newRows,
    String oldRows, [
    String? namespace,
  ]) {
    namespace = namespace ?? defaultNamespace;
    return [
      dropTriggerIfExists(
          '${opType.text.toLowerCase()}_${namespace}_${tableName}_into_oplog',
          tableName,
          namespace),
      ...createOplogTrigger(
        opType,
        tableName,
        newPKs,
        newRows,
        oldRows,
        namespace,
      ),
    ];
  }

  /// Creates or replaces a trigger that logs insertions into the oplog.
  List<String> createOrReplaceInsertTrigger(
    String tableName,
    String newPKs,
    String newRows,
    String oldRows, [
    String? namespace,
  ]) {
    return createOrReplaceOplogTrigger(
      SqlOpType.insert,
      tableName,
      newPKs,
      newRows,
      oldRows,
      namespace,
    );
  }

  /// Creates or replaces a trigger that logs updates into the oplog.
  List<String> createOrReplaceUpdateTrigger(
    String tableName,
    String newPKs,
    String newRows,
    String oldRows, [
    String? namespace,
  ]) {
    return createOrReplaceOplogTrigger(
      SqlOpType.update,
      tableName,
      newPKs,
      newRows,
      oldRows,
      namespace,
    );
  }

  /// Creates or replaces a trigger that logs deletions into the oplog.
  List<String> createOrReplaceDeleteTrigger(
    String tableName,
    String newPKs,
    String newRows,
    String oldRows, [
    String? namespace,
  ]) {
    return createOrReplaceOplogTrigger(
      SqlOpType.delete,
      tableName,
      newPKs,
      newRows,
      oldRows,
      namespace,
    );
  }

/*   /// Creates a trigger that logs compensations for operations into the oplog.
  abstract createFkCompensationTrigger(
    opType: 'INSERT' | 'UPDATE',
    tableName: string,
    childKey: string,
    fkTableName: string,
    joinedFkPKs: string,
    foreignKey: ForeignKey,
    namespace?: string,
    fkTableNamespace?: string
  ): string[]

  createOrReplaceFkCompensationTrigger(
    opType: 'INSERT' | 'UPDATE',
    tableName: string,
    childKey: string,
    fkTableName: string,
    joinedFkPKs: string,
    foreignKey: ForeignKey,
    namespace: string = this.defaultNamespace,
    fkTableNamespace: string = this.defaultNamespace
  ): string[] {
    return [
      this.dropTriggerIfExists(
        `compensation_${opType.toLowerCase()}_${namespace}_${tableName}_${childKey}_into_oplog`,
        tableName,
        namespace
      ),
      ...this.createFkCompensationTrigger(
        opType,
        tableName,
        childKey,
        fkTableName,
        joinedFkPKs,
        foreignKey,
        namespace,
        fkTableNamespace
      ),
    ]
  }

  /// Creates a trigger that logs compensations for insertions into the oplog.
  createOrReplaceInsertCompensationTrigger =
    this.createOrReplaceFkCompensationTrigger.bind(this, 'INSERT')

  /// Creates a trigger that logs compensations for updates into the oplog.
  createOrReplaceUpdateCompensationTrigger =
    this.createOrReplaceFkCompensationTrigger.bind(this, 'UPDATE')

  /// For each affected shadow row, set new tag array, unless the last oplog operation was a DELETE
  abstract setTagsForShadowRows(
    oplogTable: QualifiedTablename,
    shadowTable: QualifiedTablename
  ): string

  /// Deletes any shadow rows where the last oplog operation was a `DELETE`
  abstract removeDeletedShadowRows(
    oplogTable: QualifiedTablename,
    shadowTable: QualifiedTablename
  ): string

  /// Prepare multiple batched insert statements for an array of records.
  ///
  /// Since SQLite only supports a limited amount of positional `?` parameters,
  /// we generate multiple insert statements with each one being filled as much
  /// as possible from the given data. All statements are derived from same `baseSql` -
  /// the positional parameters will be appended to this string.
  ///
  /// @param baseSql base SQL string to which inserts should be appended
  /// @param columns columns that describe records
  /// @param records records to be inserted
  /// @param maxParameters max parameters this SQLite can accept - determines batching factor
  /// @param suffixSql optional SQL string to append to each insert statement
  /// @returns array of statements ready to be executed by the adapter
  prepareInsertBatchedStatements(
    baseSql: string,
    columns: string[],
    records: Record<string, SqlValue>[],
    maxParameters: number,
    suffixSql = ''
  ): Statement[] {
    const stmts: Statement[] = []
    const columnCount = columns.length
    const recordCount = records.length
    let processed = 0
    let positionalParam = 1
    const pos = (i: number) => `${this.makePositionalParam(i)}`
    const makeInsertPattern = () => {
      return ` (${Array.from(
        { length: columnCount },
        () => `${pos(positionalParam++)}`
      ).join(', ')})`
    }

    // Largest number below maxSqlParamers that evenly divides by column count,
    // divided by columnCount, giving the amount of rows we can insert at once
    const batchMaxSize =
      (maxParameters - (maxParameters % columnCount)) / columnCount
    while (processed < recordCount) {
      positionalParam = 1 // start counting parameters from 1 again
      const currentInsertCount = Math.min(recordCount - processed, batchMaxSize)
      let sql =
        baseSql +
        Array.from({ length: currentInsertCount }, makeInsertPattern).join(',')

      if (suffixSql !== '') {
        sql += ' ' + suffixSql
      }

      const args = records
        .slice(processed, processed + currentInsertCount)
        .flatMap((record) => columns.map((col) => record[col] as SqlValue))

      processed += currentInsertCount
      stmts.push({ sql, args })
    }
    return stmts
  }  */
}
