import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/satellite/config.dart';

List<Migration> buildInitialMigration(QueryBuilder builder) {
  final defaults = satelliteDefaults(builder.defaultNamespace);

  final oplogTable = defaults.oplogTable;
  final metaTable = defaults.metaTable;
  final migrationsTable = defaults.migrationsTable;
  final triggersTable = defaults.triggersTable;
  final shadowTable = defaults.shadowTable;

  return [
    Migration(
      statements: [
        //"-- The ops log table\n",
        '''CREATE TABLE IF NOT EXISTS "${oplogTable.namespace}"."${oplogTable.tablename}" (\n  "rowid" ${builder.autoincrementPkType},\n  "namespace" TEXT NOT NULL,\n  "tablename" TEXT NOT NULL,\n  "optype" TEXT NOT NULL,\n  "primaryKey" TEXT NOT NULL,\n  "newRow" TEXT,\n  "oldRow" TEXT,\n  "timestamp" TEXT,  "clearTags" TEXT DEFAULT '[]' NOT NULL\n);''',
        // Add an index for the oplog
        builder.createIndex('_electric_table_pk_reference', oplogTable, [
          'namespace',
          'tablename',
          'primaryKey',
        ]),
        builder.createIndex('_electric_timestamp', oplogTable, ['timestamp']),
        //"-- Somewhere to keep our metadata\n",
        'CREATE TABLE IF NOT EXISTS "${metaTable.namespace}"."${metaTable.tablename}" (\n  "key" TEXT PRIMARY KEY,\n  "value" ${builder.blobType}\n);',
        //"-- Somewhere to track migrations\n",
        'CREATE TABLE IF NOT EXISTS "${migrationsTable.namespace}"."${migrationsTable.tablename}" (\n  "id" ${builder.autoincrementPkType},\n  "version" TEXT NOT NULL UNIQUE,\n  "applied_at" TEXT NOT NULL\n);',
        //"-- Initialisation of the metadata table\n",
        '''INSERT INTO "${metaTable.namespace}"."${metaTable.tablename}" (key, value) VALUES ('compensations', 1), ('lsn', ''), ('clientId', ''), ('subscriptions', ''), ('seenAdditionalData', '');''',
        //"-- These are toggles for turning the triggers on and off\n",
        'DROP TABLE IF EXISTS "${triggersTable.namespace}"."${triggersTable.tablename}";',
        'CREATE TABLE "${triggersTable.namespace}"."${triggersTable.tablename}" ("namespace" TEXT, "tablename" TEXT, "flag" INTEGER, PRIMARY KEY ("namespace", "tablename"));',
        //"-- Somewhere to keep dependency tracking information\n",
        'CREATE TABLE "${shadowTable.namespace}"."${shadowTable.tablename}" (\n ${builder.pgOnly('"rowid" SERIAL,')} "namespace" TEXT NOT NULL,\n  "tablename" TEXT NOT NULL,\n  "primaryKey" TEXT NOT NULL,\n  "tags" TEXT NOT NULL,\n  PRIMARY KEY ("namespace", "tablename", "primaryKey"));',
      ],
      version: '0',
    ),
  ];
}
