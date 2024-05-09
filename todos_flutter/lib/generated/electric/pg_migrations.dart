// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_use_package_imports, depend_on_referenced_packages
// ignore_for_file: prefer_double_quotes

import 'package:electricsql/electricsql.dart';

const kPostgresMigrations = <Migration>[
  Migration(
    statements: [
      'CREATE TABLE todolist (\n    id text NOT NULL,\n    filter text,\n    editing text,\n    CONSTRAINT todolist_pkey PRIMARY KEY (id)\n)',
      'INSERT INTO "public"."_electric_trigger_settings" ("namespace", "tablename", "flag")\nVALUES (\'public\', \'todolist\', 1)\nON CONFLICT DO NOTHING;\n',
      'DROP TRIGGER IF EXISTS update_ensure_public_todolist_primarykey ON "public"."todolist";',
      '        CREATE OR REPLACE FUNCTION update_ensure_public_todolist_primarykey_function()\n        RETURNS TRIGGER AS \$\$\n        BEGIN\n          IF OLD."id" IS DISTINCT FROM NEW."id" THEN\n            RAISE EXCEPTION \'Cannot change the value of column id as it belongs to the primary key\';\n          END IF;\n          RETURN NEW;\n        END;\n        \$\$ LANGUAGE plpgsql;\n      ',
      '        CREATE TRIGGER update_ensure_public_todolist_primarykey\n          BEFORE UPDATE ON "public"."todolist"\n            FOR EACH ROW\n              EXECUTE FUNCTION update_ensure_public_todolist_primarykey_function();\n      ',
      'DROP TRIGGER IF EXISTS insert_public_todolist_into_oplog ON "public"."todolist";',
      '        CREATE OR REPLACE FUNCTION insert_public_todolist_into_oplog_function()\n        RETURNS TRIGGER AS \$\$\n        BEGIN\n          DECLARE\n            flag_value INTEGER;\n          BEGIN\n            -- Get the flag value from _electric_trigger_settings\n            SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = \'public\' AND tablename = \'todolist\';\n    \n            IF flag_value = 1 THEN\n              -- Insert into _electric_oplog\n              INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)\n              VALUES (\n                \'public\',\n                \'todolist\',\n                \'INSERT\',\n                json_strip_nulls(json_build_object(\'id\', new."id")),\n                jsonb_build_object(\'editing\', new."editing", \'filter\', new."filter", \'id\', new."id"),\n                NULL,\n                NULL\n              );\n            END IF;\n    \n            RETURN NEW;\n          END;\n        END;\n        \$\$ LANGUAGE plpgsql;\n      ',
      '        CREATE TRIGGER insert_public_todolist_into_oplog\n          AFTER INSERT ON "public"."todolist"\n            FOR EACH ROW\n              EXECUTE FUNCTION insert_public_todolist_into_oplog_function();\n      ',
      'DROP TRIGGER IF EXISTS update_public_todolist_into_oplog ON "public"."todolist";',
      '        CREATE OR REPLACE FUNCTION update_public_todolist_into_oplog_function()\n        RETURNS TRIGGER AS \$\$\n        BEGIN\n          DECLARE\n            flag_value INTEGER;\n          BEGIN\n            -- Get the flag value from _electric_trigger_settings\n            SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = \'public\' AND tablename = \'todolist\';\n    \n            IF flag_value = 1 THEN\n              -- Insert into _electric_oplog\n              INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)\n              VALUES (\n                \'public\',\n                \'todolist\',\n                \'UPDATE\',\n                json_strip_nulls(json_build_object(\'id\', new."id")),\n                jsonb_build_object(\'editing\', new."editing", \'filter\', new."filter", \'id\', new."id"),\n                jsonb_build_object(\'editing\', old."editing", \'filter\', old."filter", \'id\', old."id"),\n                NULL\n              );\n            END IF;\n    \n            RETURN NEW;\n          END;\n        END;\n        \$\$ LANGUAGE plpgsql;\n      ',
      '        CREATE TRIGGER update_public_todolist_into_oplog\n          AFTER UPDATE ON "public"."todolist"\n            FOR EACH ROW\n              EXECUTE FUNCTION update_public_todolist_into_oplog_function();\n      ',
      'DROP TRIGGER IF EXISTS delete_public_todolist_into_oplog ON "public"."todolist";',
      '        CREATE OR REPLACE FUNCTION delete_public_todolist_into_oplog_function()\n        RETURNS TRIGGER AS \$\$\n        BEGIN\n          DECLARE\n            flag_value INTEGER;\n          BEGIN\n            -- Get the flag value from _electric_trigger_settings\n            SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = \'public\' AND tablename = \'todolist\';\n    \n            IF flag_value = 1 THEN\n              -- Insert into _electric_oplog\n              INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)\n              VALUES (\n                \'public\',\n                \'todolist\',\n                \'DELETE\',\n                json_strip_nulls(json_build_object(\'id\', old."id")),\n                NULL,\n                jsonb_build_object(\'editing\', old."editing", \'filter\', old."filter", \'id\', old."id"),\n                NULL\n              );\n            END IF;\n    \n            RETURN NEW;\n          END;\n        END;\n        \$\$ LANGUAGE plpgsql;\n      ',
      '        CREATE TRIGGER delete_public_todolist_into_oplog\n          AFTER DELETE ON "public"."todolist"\n            FOR EACH ROW\n              EXECUTE FUNCTION delete_public_todolist_into_oplog_function();\n      ',
    ],
    version: '20230924100310',
  ),
  Migration(
    statements: [
      'CREATE TABLE todo (\n    id text NOT NULL,\n    listid text,\n    text text,\n    completed boolean NOT NULL,\n    edited_at timestamp with time zone NOT NULL,\n    CONSTRAINT todo_pkey PRIMARY KEY (id),\n    CONSTRAINT todo_listid_fkey FOREIGN KEY (listid) REFERENCES todolist(id)\n)',
      'INSERT INTO "public"."_electric_trigger_settings" ("namespace", "tablename", "flag")\nVALUES (\'public\', \'todo\', 1)\nON CONFLICT DO NOTHING;\n',
      'DROP TRIGGER IF EXISTS update_ensure_public_todo_primarykey ON "public"."todo";',
      '        CREATE OR REPLACE FUNCTION update_ensure_public_todo_primarykey_function()\n        RETURNS TRIGGER AS \$\$\n        BEGIN\n          IF OLD."id" IS DISTINCT FROM NEW."id" THEN\n            RAISE EXCEPTION \'Cannot change the value of column id as it belongs to the primary key\';\n          END IF;\n          RETURN NEW;\n        END;\n        \$\$ LANGUAGE plpgsql;\n      ',
      '        CREATE TRIGGER update_ensure_public_todo_primarykey\n          BEFORE UPDATE ON "public"."todo"\n            FOR EACH ROW\n              EXECUTE FUNCTION update_ensure_public_todo_primarykey_function();\n      ',
      'DROP TRIGGER IF EXISTS insert_public_todo_into_oplog ON "public"."todo";',
      '        CREATE OR REPLACE FUNCTION insert_public_todo_into_oplog_function()\n        RETURNS TRIGGER AS \$\$\n        BEGIN\n          DECLARE\n            flag_value INTEGER;\n          BEGIN\n            -- Get the flag value from _electric_trigger_settings\n            SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = \'public\' AND tablename = \'todo\';\n    \n            IF flag_value = 1 THEN\n              -- Insert into _electric_oplog\n              INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)\n              VALUES (\n                \'public\',\n                \'todo\',\n                \'INSERT\',\n                json_strip_nulls(json_build_object(\'id\', new."id")),\n                jsonb_build_object(\'completed\', new."completed", \'edited_at\', new."edited_at", \'id\', new."id", \'listid\', new."listid", \'text\', new."text"),\n                NULL,\n                NULL\n              );\n            END IF;\n    \n            RETURN NEW;\n          END;\n        END;\n        \$\$ LANGUAGE plpgsql;\n      ',
      '        CREATE TRIGGER insert_public_todo_into_oplog\n          AFTER INSERT ON "public"."todo"\n            FOR EACH ROW\n              EXECUTE FUNCTION insert_public_todo_into_oplog_function();\n      ',
      'DROP TRIGGER IF EXISTS update_public_todo_into_oplog ON "public"."todo";',
      '        CREATE OR REPLACE FUNCTION update_public_todo_into_oplog_function()\n        RETURNS TRIGGER AS \$\$\n        BEGIN\n          DECLARE\n            flag_value INTEGER;\n          BEGIN\n            -- Get the flag value from _electric_trigger_settings\n            SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = \'public\' AND tablename = \'todo\';\n    \n            IF flag_value = 1 THEN\n              -- Insert into _electric_oplog\n              INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)\n              VALUES (\n                \'public\',\n                \'todo\',\n                \'UPDATE\',\n                json_strip_nulls(json_build_object(\'id\', new."id")),\n                jsonb_build_object(\'completed\', new."completed", \'edited_at\', new."edited_at", \'id\', new."id", \'listid\', new."listid", \'text\', new."text"),\n                jsonb_build_object(\'completed\', old."completed", \'edited_at\', old."edited_at", \'id\', old."id", \'listid\', old."listid", \'text\', old."text"),\n                NULL\n              );\n            END IF;\n    \n            RETURN NEW;\n          END;\n        END;\n        \$\$ LANGUAGE plpgsql;\n      ',
      '        CREATE TRIGGER update_public_todo_into_oplog\n          AFTER UPDATE ON "public"."todo"\n            FOR EACH ROW\n              EXECUTE FUNCTION update_public_todo_into_oplog_function();\n      ',
      'DROP TRIGGER IF EXISTS delete_public_todo_into_oplog ON "public"."todo";',
      '        CREATE OR REPLACE FUNCTION delete_public_todo_into_oplog_function()\n        RETURNS TRIGGER AS \$\$\n        BEGIN\n          DECLARE\n            flag_value INTEGER;\n          BEGIN\n            -- Get the flag value from _electric_trigger_settings\n            SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = \'public\' AND tablename = \'todo\';\n    \n            IF flag_value = 1 THEN\n              -- Insert into _electric_oplog\n              INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)\n              VALUES (\n                \'public\',\n                \'todo\',\n                \'DELETE\',\n                json_strip_nulls(json_build_object(\'id\', old."id")),\n                NULL,\n                jsonb_build_object(\'completed\', old."completed", \'edited_at\', old."edited_at", \'id\', old."id", \'listid\', old."listid", \'text\', old."text"),\n                NULL\n              );\n            END IF;\n    \n            RETURN NEW;\n          END;\n        END;\n        \$\$ LANGUAGE plpgsql;\n      ',
      '        CREATE TRIGGER delete_public_todo_into_oplog\n          AFTER DELETE ON "public"."todo"\n            FOR EACH ROW\n              EXECUTE FUNCTION delete_public_todo_into_oplog_function();\n      ',
      'DROP TRIGGER IF EXISTS compensation_insert_public_todo_listid_into_oplog ON "public"."todo";',
      '        CREATE OR REPLACE FUNCTION compensation_insert_public_todo_listid_into_oplog_function()\n        RETURNS TRIGGER AS \$\$\n        BEGIN\n          DECLARE\n            flag_value INTEGER;\n            meta_value INTEGER;\n          BEGIN\n            SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = \'public\' AND tablename = \'todo\';\n    \n            SELECT value INTO meta_value FROM "public"._electric_meta WHERE key = \'compensations\';\n    \n            IF flag_value = 1 AND meta_value = 1 THEN\n              INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)\n              SELECT\n                \'public\',\n                \'todolist\',\n                \'COMPENSATION\',\n                json_strip_nulls(json_strip_nulls(json_build_object(\'id\', "id"))),\n                jsonb_build_object(\'id\', "id"),\n                NULL,\n                NULL\n              FROM "public"."todolist"\n              WHERE "id" = NEW."listid";\n            END IF;\n    \n            RETURN NEW;\n          END;\n        END;\n        \$\$ LANGUAGE plpgsql;\n        ',
      '          CREATE TRIGGER compensation_insert_public_todo_listid_into_oplog\n            AFTER INSERT ON "public"."todo"\n              FOR EACH ROW\n                EXECUTE FUNCTION compensation_insert_public_todo_listid_into_oplog_function();\n        ',
      'DROP TRIGGER IF EXISTS compensation_update_public_todo_listid_into_oplog ON "public"."todo";',
      '        CREATE OR REPLACE FUNCTION compensation_update_public_todo_listid_into_oplog_function()\n        RETURNS TRIGGER AS \$\$\n        BEGIN\n          DECLARE\n            flag_value INTEGER;\n            meta_value INTEGER;\n          BEGIN\n            SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = \'public\' AND tablename = \'todo\';\n    \n            SELECT value INTO meta_value FROM "public"._electric_meta WHERE key = \'compensations\';\n    \n            IF flag_value = 1 AND meta_value = 1 THEN\n              INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)\n              SELECT\n                \'public\',\n                \'todolist\',\n                \'COMPENSATION\',\n                json_strip_nulls(json_strip_nulls(json_build_object(\'id\', "id"))),\n                jsonb_build_object(\'id\', "id"),\n                NULL,\n                NULL\n              FROM "public"."todolist"\n              WHERE "id" = NEW."listid";\n            END IF;\n    \n            RETURN NEW;\n          END;\n        END;\n        \$\$ LANGUAGE plpgsql;\n        ',
      '          CREATE TRIGGER compensation_update_public_todo_listid_into_oplog\n            AFTER UPDATE ON "public"."todo"\n              FOR EACH ROW\n                EXECUTE FUNCTION compensation_update_public_todo_listid_into_oplog_function();\n        ',
    ],
    version: '20230924100404',
  ),
];
