import 'dart:convert';

import 'package:electricsql/electricsql.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/drivers/sqlite3/sqlite3.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/sockets/mock.dart';
import 'package:electricsql/src/util/proto.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

String encodeSatOpMigrateMsg(SatOpMigrate request) {
  final msgEncoded = encodeMessage(request);
  return base64.encode(msgEncoded);
}

void main() {
  final MetaData metaData = MetaData(
    format: 'SatOpMigrate',
    ops: [
      SatOpMigrate(
        version: '20230613112725_814',
        stmts: [
          SatOpMigrate_Stmt(
            type: SatOpMigrate_Type.CREATE_TABLE,
            sql:
                'CREATE TABLE "stars" (\n  "id" TEXT NOT NULL,\n  "avatar_url" TEXT NOT NULL,\n  "name" TEXT,\n  "starred_at" TEXT NOT NULL,\n  "username" TEXT NOT NULL,\n  CONSTRAINT "stars_pkey" PRIMARY KEY ("id")\n) WITHOUT ROWID;\n',
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

  test('generate migration from meta data', () {
    final migration = makeMigration(metaData);
    expect(migration.version, metaData.version);
    expect(
      migration.statements[0],
      'CREATE TABLE "stars" (\n  "id" TEXT NOT NULL,\n  "avatar_url" TEXT NOT NULL,\n  "name" TEXT,\n  "starred_at" TEXT NOT NULL,\n  "username" TEXT NOT NULL,\n  CONSTRAINT "stars_pkey" PRIMARY KEY ("id")\n) WITHOUT ROWID;\n',
    );
    expect(
      migration.statements[3],
      "\n    CREATE TRIGGER update_ensure_main_stars_primarykey\n      BEFORE UPDATE ON \"main\".\"stars\"\n    BEGIN\n      SELECT\n        CASE\n          WHEN old.\"id\" != new.\"id\" THEN\n\t\tRAISE (ABORT, 'cannot change the value of column id as it belongs to the primary key')\n        END;\n    END;\n    ",
    );
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
                    'CREATE TABLE "tenants" (\n  "id" TEXT NOT NULL,\n  "name" TEXT NOT NULL,\n  CONSTRAINT "tenants_pkey" PRIMARY KEY ("id")\n) WITHOUT ROWID;\n',
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
                    'CREATE TABLE "users" (\n  "id" TEXT NOT NULL,\n  "name" TEXT NOT NULL,\n  "email" TEXT NOT NULL,\n  "password_hash" TEXT NOT NULL,\n  CONSTRAINT "users_pkey" PRIMARY KEY ("id")\n) WITHOUT ROWID;\n',
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
                    'CREATE TABLE "tenant_users" (\n  "tenant_id" TEXT NOT NULL,\n  "user_id" TEXT NOT NULL,\n  CONSTRAINT "tenant_users_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants" ("id") ON DELETE CASCADE,\n  CONSTRAINT "tenant_users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE,\n  CONSTRAINT "tenant_users_pkey" PRIMARY KEY ("tenant_id", "user_id")\n) WITHOUT ROWID;\n',
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
    makeMigration(metaData);
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
    final migration = makeMigration(metaData);
    expect(migration.version == metaData.version, isTrue);
    expect(migration.statements, [
      'CREATE INDEX idx_stars_username ON stars(username);',
    ]);
  });

  test('load migration from meta data', () async {
    const dbName = 'memory';
    final db = sqlite3.openInMemory();
    final migration = makeMigration(metaData);
    final electric = await electrify(
      db: db,
      dbName: dbName,
      dbDescription: DBSchemaRaw(fields: {}, migrations: [migration]),
      config: ElectricConfig(
        auth: const AuthConfig(
          token: 'test-token',
        ),
      ),
      opts: ElectrifyOptions(socketFactory: MockSocketFactory()),
    );

    // Check that the DB is initialized with the stars table
    final tables = await electric.adapter.query(
      Statement(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='stars';",
      ),
    );

    final starIdx = tables.indexWhere((tbl) => tbl['name'] == 'stars');
    expect(starIdx, greaterThanOrEqualTo(0)); // must exist

    final columns = await electric.adapter
        .query(
          Statement(
            'PRAGMA table_info(stars);',
          ),
        )
        .then((columns) => columns.map((column) => column['name']! as String));

    expect(columns, ['id', 'avatar_url', 'name', 'starred_at', 'username']);
  });
}
