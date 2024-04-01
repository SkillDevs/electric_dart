// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: depend_on_referenced_packages, prefer_double_quotes

import 'dart:collection';

import 'package:electricsql/electricsql.dart';

final kElectricMigrations = UnmodifiableListView<Migration>(<Migration>[
  Migration(
    statements: [
      'CREATE TABLE "todolist" (\n  "id" TEXT NOT NULL,\n  "filter" TEXT,\n  "editing" TEXT,\n  CONSTRAINT "todolist_pkey" PRIMARY KEY ("id")\n) WITHOUT ROWID;\n',
      '\n    INSERT OR IGNORE INTO _electric_trigger_settings(tablename,flag) VALUES (\'main.todolist\', 1);\n    ',
      '\n    DROP TRIGGER IF EXISTS update_ensure_main_todolist_primarykey;\n    ',
      '\n    CREATE TRIGGER update_ensure_main_todolist_primarykey\n      BEFORE UPDATE ON "main"."todolist"\n    BEGIN\n      SELECT\n        CASE\n          WHEN old."id" != new."id" THEN\n		RAISE (ABORT, \'cannot change the value of column id as it belongs to the primary key\')\n        END;\n    END;\n    ',
      '\n    DROP TRIGGER IF EXISTS insert_main_todolist_into_oplog;\n    ',
      '\n    CREATE TRIGGER insert_main_todolist_into_oplog\n       AFTER INSERT ON "main"."todolist"\n       WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == \'main.todolist\')\n    BEGIN\n      INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n      VALUES (\'main\', \'todolist\', \'INSERT\', json_object(\'id\', new."id"), json_object(\'editing\', new."editing", \'filter\', new."filter", \'id\', new."id"), NULL, NULL);\n    END;\n    ',
      '\n    DROP TRIGGER IF EXISTS update_main_todolist_into_oplog;\n    ',
      '\n    CREATE TRIGGER update_main_todolist_into_oplog\n       AFTER UPDATE ON "main"."todolist"\n       WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == \'main.todolist\')\n    BEGIN\n      INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n      VALUES (\'main\', \'todolist\', \'UPDATE\', json_object(\'id\', new."id"), json_object(\'editing\', new."editing", \'filter\', new."filter", \'id\', new."id"), json_object(\'editing\', old."editing", \'filter\', old."filter", \'id\', old."id"), NULL);\n    END;\n    ',
      '\n    DROP TRIGGER IF EXISTS delete_main_todolist_into_oplog;\n    ',
      '\n    CREATE TRIGGER delete_main_todolist_into_oplog\n       AFTER DELETE ON "main"."todolist"\n       WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == \'main.todolist\')\n    BEGIN\n      INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n      VALUES (\'main\', \'todolist\', \'DELETE\', json_object(\'id\', old."id"), NULL, json_object(\'editing\', old."editing", \'filter\', old."filter", \'id\', old."id"), NULL);\n    END;\n    ',
    ],
    version: '20230924100310',
  ),
  Migration(
    statements: [
      'CREATE TABLE "todo" (\n  "id" TEXT NOT NULL,\n  "listid" TEXT,\n  "text" TEXT,\n  "completed" INTEGER NOT NULL,\n  "edited_at" TEXT NOT NULL,\n  CONSTRAINT "todo_listid_fkey" FOREIGN KEY ("listid") REFERENCES "todolist" ("id"),\n  CONSTRAINT "todo_pkey" PRIMARY KEY ("id")\n) WITHOUT ROWID;\n',
      '\n    INSERT OR IGNORE INTO _electric_trigger_settings(tablename,flag) VALUES (\'main.todo\', 1);\n    ',
      '\n    DROP TRIGGER IF EXISTS update_ensure_main_todo_primarykey;\n    ',
      '\n    CREATE TRIGGER update_ensure_main_todo_primarykey\n      BEFORE UPDATE ON "main"."todo"\n    BEGIN\n      SELECT\n        CASE\n          WHEN old."id" != new."id" THEN\n		RAISE (ABORT, \'cannot change the value of column id as it belongs to the primary key\')\n        END;\n    END;\n    ',
      '\n    DROP TRIGGER IF EXISTS insert_main_todo_into_oplog;\n    ',
      '\n    CREATE TRIGGER insert_main_todo_into_oplog\n       AFTER INSERT ON "main"."todo"\n       WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == \'main.todo\')\n    BEGIN\n      INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n      VALUES (\'main\', \'todo\', \'INSERT\', json_object(\'id\', new."id"), json_object(\'completed\', new."completed", \'edited_at\', new."edited_at", \'id\', new."id", \'listid\', new."listid", \'text\', new."text"), NULL, NULL);\n    END;\n    ',
      '\n    DROP TRIGGER IF EXISTS update_main_todo_into_oplog;\n    ',
      '\n    CREATE TRIGGER update_main_todo_into_oplog\n       AFTER UPDATE ON "main"."todo"\n       WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == \'main.todo\')\n    BEGIN\n      INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n      VALUES (\'main\', \'todo\', \'UPDATE\', json_object(\'id\', new."id"), json_object(\'completed\', new."completed", \'edited_at\', new."edited_at", \'id\', new."id", \'listid\', new."listid", \'text\', new."text"), json_object(\'completed\', old."completed", \'edited_at\', old."edited_at", \'id\', old."id", \'listid\', old."listid", \'text\', old."text"), NULL);\n    END;\n    ',
      '\n    DROP TRIGGER IF EXISTS delete_main_todo_into_oplog;\n    ',
      '\n    CREATE TRIGGER delete_main_todo_into_oplog\n       AFTER DELETE ON "main"."todo"\n       WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == \'main.todo\')\n    BEGIN\n      INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n      VALUES (\'main\', \'todo\', \'DELETE\', json_object(\'id\', old."id"), NULL, json_object(\'completed\', old."completed", \'edited_at\', old."edited_at", \'id\', old."id", \'listid\', old."listid", \'text\', old."text"), NULL);\n    END;\n    ',
      '      DROP TRIGGER IF EXISTS compensation_insert_main_todo_listid_into_oplog;',
      '      CREATE TRIGGER compensation_insert_main_todo_listid_into_oplog\n        AFTER INSERT ON "main"."todo"\n        WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == \'main.todolist\') AND\n             1 == (SELECT value from _electric_meta WHERE key == \'compensations\')\n      BEGIN\n        INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n        SELECT \'main\', \'todolist\', \'COMPENSATION\', json_object(\'id\', "id"), json_object(\'id\', "id"), NULL, NULL\n        FROM "main"."todolist" WHERE "id" = new."listid";\n      END;\n      ',
      'DROP TRIGGER IF EXISTS compensation_update_main_todo_listid_into_oplog;',
      '      CREATE TRIGGER compensation_update_main_todo_listid_into_oplog\n         AFTER UPDATE ON "main"."todo"\n         WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == \'main.todolist\') AND\n              1 == (SELECT value from _electric_meta WHERE key == \'compensations\')\n      BEGIN\n        INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n        SELECT \'main\', \'todolist\', \'COMPENSATION\', json_object(\'id\', "id"), json_object(\'id\', "id"), NULL, NULL\n        FROM "main"."todolist" WHERE "id" = new."listid";\n      END;\n      ',
    ],
    version: '20230924100404',
  ),
]);
