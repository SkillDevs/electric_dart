import 'dart:convert';

import 'package:electricsql/migrators.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/util/proto.dart';
import 'package:electricsql/util.dart';
import 'package:test/test.dart';

String encodeSatOpMigrateMsg(SatOpMigrate request) {
  final msgEncoded = encodeMessage(request);
  return base64.encode(msgEncoded);
}

MetaData makeMigrationMetaData(QueryBuilder builder) {
  return MetaData(
    format: 'SatOpMigrate',
    ops: [
      SatOpMigrate(
        version: '20230613112725_814',
        stmts: [
          SatOpMigrate_Stmt(
            type: SatOpMigrate_Type.CREATE_TABLE,
            sql:
                'CREATE TABLE "${builder.defaultNamespace}"."stars" (\n  "id" TEXT NOT NULL PRIMARY KEY,\n  "avatar_url" TEXT NOT NULL,\n  "name" TEXT,\n  "starred_at" TEXT NOT NULL,\n  "username" TEXT NOT NULL\n);\n',
          ),
        ],
        table: SatOpMigrate_Table(
          name: 'stars',
          columns: [
            SatOpMigrate_Column(
              name: 'id',
              sqliteType: 'TEXT',
              pgType: SatOpMigrate_PgColumnType(
                name: 'text',
                array: [],
                size: [],
              ),
            ),
            SatOpMigrate_Column(
              name: 'avatar_url',
              sqliteType: 'TEXT',
              pgType: SatOpMigrate_PgColumnType(
                name: 'text',
                array: [],
                size: [],
              ),
            ),
            SatOpMigrate_Column(
              name: 'name',
              sqliteType: 'TEXT',
              pgType: SatOpMigrate_PgColumnType(
                name: 'text',
                array: [],
                size: [],
              ),
            ),
            SatOpMigrate_Column(
              name: 'starred_at',
              sqliteType: 'TEXT',
              pgType: SatOpMigrate_PgColumnType(
                name: 'text',
                array: [],
                size: [],
              ),
            ),
            SatOpMigrate_Column(
              name: 'username',
              sqliteType: 'TEXT',
              pgType: SatOpMigrate_PgColumnType(
                name: 'text',
                array: [],
                size: [],
              ),
            ),
          ],
          fks: [],
          pks: ['id'],
        ),
      ),
    ],
    protocolVersion: 'Electric.Satellite',
    version: '20230613112725_814',
  );
}

void builderTests({
  required MetaData migrationMetaData,
  required QueryBuilder builder,
}) {
  test('generate migration from meta data', () {
    final migration = makeMigration(migrationMetaData, builder);
    expect(migration.version, migrationMetaData.version);
    expect(
      migration.statements[0],
      'CREATE TABLE "${builder.defaultNamespace}"."stars" (\n  "id" TEXT NOT NULL PRIMARY KEY,\n  "avatar_url" TEXT NOT NULL,\n  "name" TEXT,\n  "starred_at" TEXT NOT NULL,\n  "username" TEXT NOT NULL\n);\n',
    );
    if (builder.dialect == Dialect.sqlite) {
      expect(
        migration.statements[3],
        '''CREATE TRIGGER update_ensure_${builder.defaultNamespace}_stars_primarykey\n  BEFORE UPDATE ON "${builder.defaultNamespace}"."stars"\nBEGIN\n  SELECT\n    CASE\n      WHEN old."id" != new."id" THEN\n      \t\tRAISE (ABORT, 'cannot change the value of column id as it belongs to the primary key')\n    END;\nEND;''',
      );
    } else {
      // Postgres
      expect(migration.statements[3], '''
        CREATE OR REPLACE FUNCTION update_ensure_${builder.defaultNamespace}_stars_primarykey_function()
        RETURNS TRIGGER AS \$\$
        BEGIN
          IF OLD."id" IS DISTINCT FROM NEW."id" THEN
            RAISE EXCEPTION 'Cannot change the value of column id as it belongs to the primary key';
          END IF;
          RETURN NEW;
        END;
        \$\$ LANGUAGE plpgsql;
      ''');

      expect(migration.statements[4], '''
        CREATE TRIGGER update_ensure_${builder.defaultNamespace}_stars_primarykey
          BEFORE UPDATE ON "${builder.defaultNamespace}"."stars"
            FOR EACH ROW
              EXECUTE FUNCTION update_ensure_${builder.defaultNamespace}_stars_primarykey_function();
      ''');
    }
  });

  test('make migration for table with FKs', () async {
    final migration = <String, Object?>{
      'format': 'SatOpMigrate',
      'ops': [
        encodeSatOpMigrateMsg(
          SatOpMigrate(
            version: '1',
            stmts: [
              SatOpMigrate_Stmt(
                type: SatOpMigrate_Type.CREATE_TABLE,
                sql:
                    'CREATE TABLE "${builder.defaultNamespace}"."tenants" (\n  "id" TEXT NOT NULL,\n  "name" TEXT NOT NULL,\n  CONSTRAINT "tenants_pkey" PRIMARY KEY ("id")\n);\n',
              ),
            ],
            table: SatOpMigrate_Table(
              name: 'tenants',
              columns: [
                SatOpMigrate_Column(
                  name: 'id',
                  sqliteType: 'TEXT',
                  pgType: SatOpMigrate_PgColumnType(
                    name: 'uuid',
                    array: [],
                    size: [],
                  ),
                ),
                SatOpMigrate_Column(
                  name: 'name',
                  sqliteType: 'TEXT',
                  pgType: SatOpMigrate_PgColumnType(
                    name: 'text',
                    array: [],
                    size: [],
                  ),
                ),
              ],
              fks: [],
              pks: ['id'],
            ),
          ),
        ),
        encodeSatOpMigrateMsg(
          SatOpMigrate(
            version: '1',
            stmts: [
              SatOpMigrate_Stmt(
                type: SatOpMigrate_Type.CREATE_TABLE,
                sql:
                    'CREATE TABLE "${builder.defaultNamespace}"."users" (\n  "id" TEXT NOT NULL,\n  "name" TEXT NOT NULL,\n  "email" TEXT NOT NULL,\n  "password_hash" TEXT NOT NULL,\n  CONSTRAINT "users_pkey" PRIMARY KEY ("id")\n);\n',
              ),
            ],
            table: SatOpMigrate_Table(
              name: 'users',
              columns: [
                SatOpMigrate_Column(
                  name: 'id',
                  sqliteType: 'TEXT',
                  pgType: SatOpMigrate_PgColumnType(
                    name: 'uuid',
                    array: [],
                    size: [],
                  ),
                ),
                SatOpMigrate_Column(
                  name: 'name',
                  sqliteType: 'TEXT',
                  pgType: SatOpMigrate_PgColumnType(
                    name: 'text',
                    array: [],
                    size: [],
                  ),
                ),
                SatOpMigrate_Column(
                  name: 'email',
                  sqliteType: 'TEXT',
                  pgType: SatOpMigrate_PgColumnType(
                    name: 'text',
                    array: [],
                    size: [],
                  ),
                ),
                SatOpMigrate_Column(
                  name: 'password_hash',
                  sqliteType: 'TEXT',
                  pgType: SatOpMigrate_PgColumnType(
                    name: 'text',
                    array: [],
                    size: [],
                  ),
                ),
              ],
              fks: [],
              pks: ['id'],
            ),
          ),
        ),
        encodeSatOpMigrateMsg(
          SatOpMigrate(
            version: '1',
            stmts: [
              SatOpMigrate_Stmt(
                type: SatOpMigrate_Type.CREATE_TABLE,
                sql:
                    'CREATE TABLE "${builder.defaultNamespace}"."tenant_users" (\n  "tenant_id" TEXT NOT NULL,\n  "user_id" TEXT NOT NULL,\n  CONSTRAINT "tenant_users_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants" ("id") ON DELETE CASCADE,\n  CONSTRAINT "tenant_users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE,\n  CONSTRAINT "tenant_users_pkey" PRIMARY KEY ("tenant_id", "user_id")\n);\n',
              ),
            ],
            table: SatOpMigrate_Table(
              name: 'tenant_users',
              columns: [
                SatOpMigrate_Column(
                  name: 'tenant_id',
                  sqliteType: 'TEXT',
                  pgType: SatOpMigrate_PgColumnType(
                    name: 'uuid',
                    array: [],
                    size: [],
                  ),
                ),
                SatOpMigrate_Column(
                  name: 'user_id',
                  sqliteType: 'TEXT',
                  pgType: SatOpMigrate_PgColumnType(
                    name: 'uuid',
                    array: [],
                    size: [],
                  ),
                ),
              ],
              fks: [
                SatOpMigrate_ForeignKey(
                  fkCols: ['tenant_id'],
                  pkTable: 'tenants',
                  pkCols: ['id'],
                ),
                SatOpMigrate_ForeignKey(
                  fkCols: ['user_id'],
                  pkTable: 'users',
                  pkCols: ['id'],
                ),
              ],
              pks: ['tenant_id', 'user_id'],
            ),
          ),
        ),
      ],
      'protocol_version': 'Electric.Satellite',
      'version': '1',
    };

    //const migrateMetaData = JSON.parse(`{"format":"SatOpMigrate","ops":["GjcKB3RlbmFudHMSEgoCaWQSBFRFWFQaBgoEdXVpZBIUCgRuYW1lEgRURVhUGgYKBHRleHQiAmlkCgExEooBEocBQ1JFQVRFIFRBQkxFICJ0ZW5hbnRzIiAoCiAgImlkIiBURVhUIE5PVCBOVUxMLAogICJuYW1lIiBURVhUIE5PVCBOVUxMLAogIENPTlNUUkFJTlQgInRlbmFudHNfcGtleSIgUFJJTUFSWSBLRVkgKCJpZCIpCikgV0lUSE9VVCBST1dJRDsK","GmsKBXVzZXJzEhIKAmlkEgRURVhUGgYKBHV1aWQSFAoEbmFtZRIEVEVYVBoGCgR0ZXh0EhUKBWVtYWlsEgRURVhUGgYKBHRleHQSHQoNcGFzc3dvcmRfaGFzaBIEVEVYVBoGCgR0ZXh0IgJpZAoBMRLAARK9AUNSRUFURSBUQUJMRSAidXNlcnMiICgKICAiaWQiIFRFWFQgTk9UIE5VTEwsCiAgIm5hbWUiIFRFWFQgTk9UIE5VTEwsCiAgImVtYWlsIiBURVhUIE5PVCBOVUxMLAogICJwYXNzd29yZF9oYXNoIiBURVhUIE5PVCBOVUxMLAogIENPTlNUUkFJTlQgInVzZXJzX3BrZXkiIFBSSU1BUlkgS0VZICgiaWQiKQopIFdJVEhPVVQgUk9XSUQ7Cg==","GoYBCgx0ZW5hbnRfdXNlcnMSGQoJdGVuYW50X2lkEgRURVhUGgYKBHV1aWQSFwoHdXNlcl9pZBIEVEVYVBoGCgR1dWlkGhgKCXRlbmFudF9pZBIHdGVuYW50cxoCaWQaFAoHdXNlcl9pZBIFdXNlcnMaAmlkIgl0ZW5hbnRfaWQiB3VzZXJfaWQKATESkgMSjwNDUkVBVEUgVEFCTEUgInRlbmFudF91c2VycyIgKAogICJ0ZW5hbnRfaWQiIFRFWFQgTk9UIE5VTEwsCiAgInVzZXJfaWQiIFRFWFQgTk9UIE5VTEwsCiAgQ09OU1RSQUlOVCAidGVuYW50X3VzZXJzX3RlbmFudF9pZF9ma2V5IiBGT1JFSUdOIEtFWSAoInRlbmFudF9pZCIpIFJFRkVSRU5DRVMgInRlbmFudHMiICgiaWQiKSBPTiBERUxFVEUgQ0FTQ0FERSwKICBDT05TVFJBSU5UICJ0ZW5hbnRfdXNlcnNfdXNlcl9pZF9ma2V5IiBGT1JFSUdOIEtFWSAoInVzZXJfaWQiKSBSRUZFUkVOQ0VTICJ1c2VycyIgKCJpZCIpIE9OIERFTEVURSBDQVNDQURFLAogIENPTlNUUkFJTlQgInRlbmFudF91c2Vyc19wa2V5IiBQUklNQVJZIEtFWSAoInRlbmFudF9pZCIsICJ1c2VyX2lkIikKKSBXSVRIT1VUIFJPV0lEOwo="],"protocol_version":"Electric.Satellite","version":"1"}`)
    final metaData = parseMetadata(migration);
    makeMigration(metaData, builder);
    // don't throw
  });

  test('generate index creation migration from meta data', () {
    final metaData = parseMetadata({
      'format': 'SatOpMigrate',
      'ops': [
        encodeSatOpMigrateMsg(
          SatOpMigrate(
            version: '20230613112725_814',
            stmts: [
              SatOpMigrate_Stmt(
                type: SatOpMigrate_Type.CREATE_INDEX,
                sql: 'CREATE INDEX idx_stars_username ON stars(username);',
              ),
            ],
          ),
        ),
      ],
      'protocol_version': 'Electric.Satellite',
      'version': '20230613112725_814',
    });
    final migration = makeMigration(metaData, builder);
    expect(migration.version == metaData.version, isTrue);
    expect(migration.statements, [
      'CREATE INDEX idx_stars_username ON stars(username);',
    ]);
  });

  test('prepareInsertBatchedStatements correctly splits up data in batches',
      () {
    const data = [
      {'a': 1, 'b': 2},
      {'a': 3, 'b': 4},
      {'a': 5, 'b': 6},
    ];
    final stmts = builder.prepareInsertBatchedStatements(
      'INSERT INTO test (a, b) VALUES',
      ['a', 'b'],
      data,
      5, // at most 5 `?`s in one SQL statement, so we should see the split
    );

    final List<String> posArgs = builder.dialect == Dialect.sqlite
        ? ['?', '?', '?', '?']
        : [r'$1', r'$2', r'$3', r'$4'];

    expect(stmts, [
      Statement(
        'INSERT INTO test (a, b) VALUES (${posArgs[0]}, ${posArgs[1]}), (${posArgs[2]}, ${posArgs[3]})',
        [1, 2, 3, 4],
      ),
      Statement(
        'INSERT INTO test (a, b) VALUES (${posArgs[0]}, ${posArgs[1]})',
        [5, 6],
      ),
    ]);
  });

  test('prepareInsertBatchedStatements respects column order', () {
    const data = [
      {'a': 1, 'b': 2},
      {'a': 3, 'b': 4},
      {'a': 5, 'b': 6},
    ];
    final stmts = builder.prepareInsertBatchedStatements(
      'INSERT INTO test (a, b) VALUES',
      ['b', 'a'],
      data,
      5,
    );

    final List<String> posArgs = builder.dialect == Dialect.sqlite
        ? ['?', '?', '?', '?']
        : [r'$1', r'$2', r'$3', r'$4'];

    expect(stmts, [
      Statement(
        'INSERT INTO test (a, b) VALUES (${posArgs[0]}, ${posArgs[1]}), (${posArgs[2]}, ${posArgs[3]})',
        [2, 1, 4, 3],
      ),
      Statement(
        'INSERT INTO test (a, b) VALUES (${posArgs[0]}, ${posArgs[1]})',
        [6, 5],
      ),
    ]);
  });

  test('prepareDeleteBatchedStatements correctly splits up data in batches',
      () {
    const data = [
      {'a': 1, 'b': 2},
      {'a': 3, 'b': 4},
      {'a': 5, 'b': 6},
    ];
    final stmts = builder.prepareDeleteBatchedStatements(
      'DELETE FROM test WHERE',
      ['a', 'b'],
      data,
      5, // at most 5 `?`s in one SQL statement, so we should see the split
    );

    final List<String> posArgs = builder.dialect == Dialect.sqlite
        ? ['?', '?', '?', '?']
        : [r'$1', r'$2', r'$3', r'$4'];

    expect(stmts, [
      Statement(
        'DELETE FROM test WHERE ("a" = ${posArgs[0]} AND "b" = ${posArgs[1]}) OR ("a" = ${posArgs[2]} AND "b" = ${posArgs[3]})',
        [1, 2, 3, 4],
      ),
      Statement(
        'DELETE FROM test WHERE ("a" = ${posArgs[0]} AND "b" = ${posArgs[1]})',
        [5, 6],
      ),
    ]);
  });

  test('prepareDeleteBatchedStatements respects column order', () {
    const data = [
      {'a': 1, 'b': 2},
      {'a': 3, 'b': 4},
      {'a': 5, 'b': 6},
    ];
    final stmts = builder.prepareDeleteBatchedStatements(
      'DELETE FROM test WHERE',
      ['b', 'a'],
      data,
      5,
    );

    final List<String> posArgs = builder.dialect == Dialect.sqlite
        ? ['?', '?', '?', '?']
        : [r'$1', r'$2', r'$3', r'$4'];

    expect(stmts, [
      Statement(
        'DELETE FROM test WHERE ("b" = ${posArgs[0]} AND "a" = ${posArgs[1]}) OR ("b" = ${posArgs[2]} AND "a" = ${posArgs[3]})',
        [2, 1, 4, 3],
      ),
      Statement(
        'DELETE FROM test WHERE ("b" = ${posArgs[0]} AND "a" = ${posArgs[1]})',
        [6, 5],
      ),
    ]);
  });
}
