import 'package:electricsql/src/migrators/migrators.dart';

const kTestPostgresMigrations = [
  Migration(
    statements: [
      'DROP TABLE IF EXISTS public._electric_trigger_settings;',
      'CREATE TABLE public._electric_trigger_settings(namespace TEXT, tablename TEXT, flag INTEGER, PRIMARY KEY (namespace, tablename));',
    ],
    version: '1',
  ),
  Migration(
    statements: [
      'CREATE TABLE IF NOT EXISTS public.items (\n  value TEXT PRIMARY KEY NOT NULL\n);',
      'CREATE TABLE IF NOT EXISTS public."bigIntTable" (\n  value BIGINT PRIMARY KEY NOT NULL\n);',
      'CREATE TABLE IF NOT EXISTS public.parent (\n  id INTEGER PRIMARY KEY NOT NULL,\n  value TEXT,\n  other INTEGER DEFAULT 0\n);',
      'CREATE TABLE IF NOT EXISTS public.child (\n  id INTEGER PRIMARY KEY NOT NULL,\n  parent INTEGER NOT NULL,\n  FOREIGN KEY(parent) REFERENCES public.parent(id) DEFERRABLE INITIALLY IMMEDIATE\n);',
      'CREATE TABLE "public"."blobTable" (value bytea NOT NULL, CONSTRAINT "blobTable_pkey" PRIMARY KEY (value)\n);',
      'DROP TABLE IF EXISTS public._electric_trigger_settings;',
      'CREATE TABLE public._electric_trigger_settings(namespace TEXT, tablename TEXT, flag INTEGER, PRIMARY KEY (namespace, tablename));',
      "INSERT INTO public._electric_trigger_settings(namespace, tablename,flag) VALUES ('public', 'child', 1);",
      "INSERT INTO public._electric_trigger_settings(namespace, tablename,flag) VALUES ('public', 'items', 1);",
      "INSERT INTO public._electric_trigger_settings(namespace, tablename,flag) VALUES ('public', 'parent', 1);",
      "INSERT INTO public._electric_trigger_settings(namespace, tablename,flag) VALUES ('public', 'bigIntTable', 1);",
      "INSERT INTO public._electric_trigger_settings(namespace, tablename,flag) VALUES ('public', 'blobTable', 1);",
      'DROP TRIGGER IF EXISTS update_ensure_public_child_primarykey ON public.child;',
      '''
      CREATE OR REPLACE FUNCTION update_ensure_public_child_primarykey_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        IF old.id != new.id THEN
          RAISE EXCEPTION 'cannot change the value of column id as it belongs to the primary key';
        END IF;
        RETURN NEW;
      END;
      \$\$ LANGUAGE plpgsql;''',
      '''
      CREATE TRIGGER update_ensure_public_child_primarykey
      BEFORE UPDATE ON public.child
      FOR EACH ROW
      EXECUTE FUNCTION update_ensure_public_child_primarykey_function();
      ''',
      'DROP TRIGGER IF EXISTS insert_public_child_into_oplog ON public.child',
      '''
      CREATE OR REPLACE FUNCTION insert_public_child_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'child';

          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES ('public', 'child', 'INSERT', json_strip_nulls(json_build_object('id', NEW.id)), jsonb_build_object('id', NEW.id, 'parent', NEW.parent), NULL, NULL);
          END IF;

          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      CREATE TRIGGER insert_public_child_into_oplog
      AFTER INSERT ON public.child
      FOR EACH ROW
      EXECUTE FUNCTION insert_public_child_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS update_public_child_into_oplog ON public.child;',
      '''
      CREATE OR REPLACE FUNCTION update_public_child_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'child';

          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES ('public', 'child', 'UPDATE', json_strip_nulls(json_build_object('id', NEW.id)), jsonb_build_object('id', NEW.id, 'parent', NEW.parent), jsonb_build_object('id', OLD.id, 'parent', OLD.parent), NULL);
          END IF;

          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      CREATE TRIGGER update_public_child_into_oplog
      AFTER UPDATE ON public.child
      FOR EACH ROW
      EXECUTE FUNCTION update_public_child_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS delete_public_child_into_oplog ON public.child;',
      '''
      CREATE OR REPLACE FUNCTION delete_public_child_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'child';

          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES ('public', 'child', 'DELETE', json_strip_nulls(json_build_object('id', OLD.id)), NULL, jsonb_build_object('id', OLD.id, 'parent', OLD.parent), NULL);
          END IF;

          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      CREATE TRIGGER delete_public_child_into_oplog
      AFTER DELETE ON public.child
      FOR EACH ROW
      EXECUTE FUNCTION delete_public_child_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS compensation_insert_public_child_parent_into_oplog ON public.child;',
      '''
      CREATE OR REPLACE FUNCTION compensation_insert_public_child_parent_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
          meta_value TEXT;
        BEGIN
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'parent';

          SELECT value INTO meta_value FROM public._electric_meta WHERE key = 'compensations';

          IF flag_value = 1 AND meta_value = '1' THEN
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            SELECT 'public', 'parent', 'INSERT', json_strip_nulls(json_build_object('id', id)),
              jsonb_build_object('id', id, 'value', value, 'other', other), NULL, NULL
            FROM public.parent WHERE id = NEW."parent";
          END IF;

          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      CREATE TRIGGER compensation_insert_public_child_parent_into_oplog
      AFTER INSERT ON public.child
      FOR EACH ROW
      EXECUTE FUNCTION compensation_insert_public_child_parent_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS compensation_update_public_child_parent_into_oplog ON public.parent;',
      '''
      CREATE OR REPLACE FUNCTION compensation_update_public_child_parent_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
          meta_value TEXT;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'parent';

          -- Get the 'compensations' value from _electric_meta
          SELECT value INTO meta_value FROM public._electric_meta WHERE key = 'compensations';

          IF flag_value = 1 AND meta_value = '1' THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            SELECT 'public', 'parent', 'UPDATE', json_strip_nulls(json_build_object('id', id)),
              jsonb_build_object('id', id, 'value', value, 'other', other), NULL, NULL
            FROM public.parent WHERE id = NEW."parent";
          END IF;

          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      CREATE TRIGGER compensation_update_public_child_parent_into_oplog
      AFTER UPDATE ON public.child
      FOR EACH ROW
      EXECUTE FUNCTION compensation_update_public_child_parent_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS update_ensure_public_items_primarykey ON public.items;',
      '''
      CREATE OR REPLACE FUNCTION update_ensure_public_items_primarykey_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        IF old.value != new.value THEN
          RAISE EXCEPTION 'cannot change the value of column value as it belongs to the primary key';
        END IF;
        RETURN NEW;
      END;
      \$\$ LANGUAGE plpgsql;''',
      '''
      CREATE TRIGGER update_ensure_public_items_primarykey
      BEFORE UPDATE ON public.items
      FOR EACH ROW
      EXECUTE FUNCTION update_ensure_public_items_primarykey_function();
      ''',
      'DROP TRIGGER IF EXISTS insert_public_items_into_oplog ON public.items;',
      '''
      CREATE OR REPLACE FUNCTION insert_public_items_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'items';

          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES ('public', 'items', 'INSERT', json_strip_nulls(json_build_object('value', NEW.value)), jsonb_build_object('value', NEW.value), NULL, NULL);
          END IF;

          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      -- Attach the trigger function to the table
      CREATE TRIGGER insert_public_items_into_oplog
      AFTER INSERT ON public.items
      FOR EACH ROW
      EXECUTE FUNCTION insert_public_items_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS update_public_items_into_oplog ON public.items;',
      '''
      CREATE OR REPLACE FUNCTION update_public_items_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'items';

          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES ('public', 'items', 'UPDATE', json_strip_nulls(json_build_object('value', NEW.value)), jsonb_build_object('value', NEW.value), jsonb_build_object('value', OLD.value), NULL);
          END IF;

          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;''',
      '''
      -- Attach the trigger function to the table
      CREATE TRIGGER update_public_items_into_oplog
      AFTER UPDATE ON public.items
      FOR EACH ROW
      EXECUTE FUNCTION update_public_items_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS delete_public_items_into_oplog ON public.items;',
      '''
      CREATE OR REPLACE FUNCTION delete_public_items_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'items';

          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES ('public', 'items', 'DELETE', json_strip_nulls(json_build_object('value', OLD.value)), NULL, jsonb_build_object('value', OLD.value), NULL);
          END IF;

          RETURN OLD;
        END;
      END;
      \$\$ LANGUAGE plpgsql;''',
      '''
      -- Attach the trigger function to the table
      CREATE TRIGGER delete_public_items_into_oplog
      AFTER DELETE ON public.items
      FOR EACH ROW
      EXECUTE FUNCTION delete_public_items_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS update_ensure_public_parent_primarykey ON public.parent;',
      '''
      CREATE OR REPLACE FUNCTION update_ensure_public_parent_primarykey_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        IF OLD.id != NEW.id THEN
          RAISE EXCEPTION 'cannot change the value of column id as it belongs to the primary key';
        END IF;
        RETURN NEW;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      -- Attach the trigger function to the table
      CREATE TRIGGER update_ensure_public_parent_primarykey
      BEFORE UPDATE ON public.parent
      FOR EACH ROW
      EXECUTE FUNCTION update_ensure_public_parent_primarykey_function();
      ''',
      'DROP TRIGGER IF EXISTS insert_public_parent_into_oplog ON public.parent;',
      '''
      CREATE OR REPLACE FUNCTION insert_public_parent_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'parent';

          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES (
              'public',
              'parent',
              'INSERT',
              json_strip_nulls(json_build_object('id', NEW.id)),
              jsonb_build_object('id', NEW.id, 'value', NEW.value, 'other', NEW.other),
              NULL,
              NULL
            );
          END IF;

          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      -- Attach the trigger function to the table
      CREATE TRIGGER insert_public_parent_into_oplog
      AFTER INSERT ON public.parent
      FOR EACH ROW
      EXECUTE FUNCTION insert_public_parent_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS update_public_parent_into_oplog ON public.parent;',
      '''
      CREATE OR REPLACE FUNCTION update_public_parent_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'parent';

          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES (
              'public',
              'parent',
              'UPDATE',
              json_strip_nulls(json_build_object('id', NEW.id)),
              jsonb_build_object('id', NEW.id, 'value', NEW.value, 'other', NEW.other),
              jsonb_build_object('id', OLD.id, 'value', OLD.value, 'other', OLD.other),
              NULL
            );
          END IF;

          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      -- Attach the trigger function to the table
      CREATE TRIGGER update_public_parent_into_oplog
      AFTER UPDATE ON public.parent
      FOR EACH ROW
      EXECUTE FUNCTION update_public_parent_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS delete_public_parent_into_oplog ON public.parent;',
      '''
      CREATE OR REPLACE FUNCTION delete_public_parent_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'parent';

          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES (
              'public',
              'parent',
              'DELETE',
              json_strip_nulls(json_build_object('id', OLD.id)),
              NULL,
              jsonb_build_object('id', OLD.id, 'value', OLD.value, 'other', OLD.other),
              NULL
            );
          END IF;

          RETURN OLD;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      -- Attach the trigger function to the table
      CREATE TRIGGER delete_public_parent_into_oplog
      AFTER DELETE ON public.parent
      FOR EACH ROW
      EXECUTE FUNCTION delete_public_parent_into_oplog_function();
      ''',
      '''
      -- Toggles for turning the triggers on and off
      INSERT INTO "public"."_electric_trigger_settings" ("namespace", "tablename", "flag")
        VALUES ('public', 'bigIntTable', 1)
        ON CONFLICT DO NOTHING;
      ''',
      '''
      /* Triggers for table bigIntTable */

      -- ensures primary key is immutable
      DROP TRIGGER IF EXISTS update_ensure_public_bigIntTable_primarykey ON "public"."bigIntTable";
      ''',
      '''
      CREATE OR REPLACE FUNCTION update_ensure_public_bigIntTable_primarykey_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        IF OLD."value" IS DISTINCT FROM NEW."value" THEN
          RAISE EXCEPTION 'Cannot change the value of column value as it belongs to the primary key';
        END IF;
        RETURN NEW;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      CREATE TRIGGER update_ensure_public_bigIntTable_primarykey
        BEFORE UPDATE ON "public"."bigIntTable"
          FOR EACH ROW
            EXECUTE FUNCTION update_ensure_public_bigIntTable_primarykey_function();
      ''',
      '''
      -- Triggers that add INSERT, UPDATE, DELETE operation to the oplog table
      DROP TRIGGER IF EXISTS insert_public_bigIntTable_into_oplog ON "public"."bigIntTable";
      ''',
      '''
      CREATE OR REPLACE FUNCTION insert_public_bigIntTable_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'bigIntTable';
  
          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES (
              'public',
              'bigIntTable',
              'INSERT',
              json_strip_nulls(json_build_object('value', cast(new."value" as TEXT))),
              jsonb_build_object('value', cast(new."value" as TEXT)),
              NULL,
              NULL
            );
          END IF;
  
          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      CREATE TRIGGER insert_public_bigIntTable_into_oplog
        AFTER INSERT ON "public"."bigIntTable"
          FOR EACH ROW
            EXECUTE FUNCTION insert_public_bigIntTable_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS update_public_bigIntTable_into_oplog ON "public"."bigIntTable";',
      '''
      CREATE OR REPLACE FUNCTION update_public_bigIntTable_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'bigIntTable';
  
          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES (
              'public',
              'bigIntTable',
              'UPDATE',
              json_strip_nulls(json_build_object('value', cast(new."value" as TEXT))),
              jsonb_build_object('value', cast(new."value" as TEXT)),
              jsonb_build_object('value', cast(old."value" as TEXT)),
              NULL
            );
          END IF;
  
          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      CREATE TRIGGER update_public_bigIntTable_into_oplog
        AFTER UPDATE ON "public"."bigIntTable"
          FOR EACH ROW
            EXECUTE FUNCTION update_public_bigIntTable_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS delete_public_bigIntTable_into_oplog ON "public"."bigIntTable";',
      '''
      CREATE OR REPLACE FUNCTION delete_public_bigIntTable_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'bigIntTable';
  
          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO public._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES (
              'public',
              'bigIntTable',
              'DELETE',
              json_strip_nulls(json_build_object('value', cast(old."value" as TEXT))),
              NULL,
              jsonb_build_object('value', cast(old."value" as TEXT)),
              NULL
            );
          END IF;
  
          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      '''
      CREATE TRIGGER delete_public_bigIntTable_into_oplog
        AFTER DELETE ON "public"."bigIntTable"
          FOR EACH ROW
            EXECUTE FUNCTION delete_public_bigIntTable_into_oplog_function();
      ''',
      'DROP TRIGGER IF EXISTS update_ensure_public_blobTable_primarykey ON "public"."blobTable";',
      'CREATE OR REPLACE FUNCTION update_ensure_public_blobTable_primarykey_function()\nRETURNS TRIGGER AS \$\$\nBEGIN\n  IF OLD."value" IS DISTINCT FROM NEW."value" THEN\n    RAISE EXCEPTION \'Cannot change the value of column value as it belongs to the primary key\';\n  END IF;\n  RETURN NEW;\nEND;\n\$\$ LANGUAGE plpgsql;',
      'CREATE TRIGGER update_ensure_public_blobTable_primarykey\n  BEFORE UPDATE ON "public"."blobTable"\n    FOR EACH ROW\n      EXECUTE FUNCTION update_ensure_public_blobTable_primarykey_function();',
      'DROP TRIGGER IF EXISTS insert_public_blobTable_into_oplog ON "public"."blobTable";',
      "CREATE OR REPLACE FUNCTION insert_public_blobTable_into_oplog_function()\n    RETURNS TRIGGER AS \$\$\n    BEGIN\n      DECLARE\n        flag_value INTEGER;\n      BEGIN\n        -- Get the flag value from _electric_trigger_settings\n        SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'blobTable';\n\n        IF flag_value = 1 THEN\n          -- Insert into _electric_oplog\n          INSERT INTO public._electric_oplog (namespace, tablename, optype, \"primaryKey\", \"newRow\", \"oldRow\", timestamp)\n          VALUES (\n            'public',\n            'blobTable',\n            'INSERT',\n            json_strip_nulls(json_build_object('value', CASE WHEN new.\"value\" IS NOT NULL THEN encode(new.\"value\"::bytea, 'hex') ELSE NULL END)),\n            jsonb_build_object('value', CASE WHEN new.\"value\" IS NOT NULL THEN encode(new.\"value\"::bytea, 'hex') ELSE NULL END),\n            NULL,\n            NULL\n          );\n        END IF;\n\n        RETURN NEW;\n      END;\n    END;\n    \$\$ LANGUAGE plpgsql;",
      'CREATE TRIGGER insert_public_blobTable_into_oplog\n  AFTER INSERT ON "public"."blobTable"\n    FOR EACH ROW\n      EXECUTE FUNCTION insert_public_blobTable_into_oplog_function();',
      'DROP TRIGGER IF EXISTS update_public_blobTable_into_oplog ON "public"."blobTable";',
      "CREATE OR REPLACE FUNCTION update_public_blobTable_into_oplog_function()\n    RETURNS TRIGGER AS \$\$\n    BEGIN\n      DECLARE\n        flag_value INTEGER;\n      BEGIN\n        -- Get the flag value from _electric_trigger_settings\n        SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'blobTable';\n\n        IF flag_value = 1 THEN\n          -- Insert into _electric_oplog\n          INSERT INTO public._electric_oplog (namespace, tablename, optype, \"primaryKey\", \"newRow\", \"oldRow\", timestamp)\n          VALUES (\n            'public',\n            'blobTable',\n            'UPDATE',\n            json_strip_nulls(json_build_object('value', CASE WHEN new.\"value\" IS NOT NULL THEN encode(new.\"value\"::bytea, 'hex') ELSE NULL END)),\n            jsonb_build_object('value', CASE WHEN new.\"value\" IS NOT NULL THEN encode(new.\"value\"::bytea, 'hex') ELSE NULL END),\n            jsonb_build_object('value', CASE WHEN old.\"value\" IS NOT NULL THEN encode(old.\"value\"::bytea, 'hex') ELSE NULL END),\n            NULL\n          );\n        END IF;\n\n        RETURN NEW;\n      END;\n    END;\n    \$\$ LANGUAGE plpgsql;",
      'CREATE TRIGGER update_public_blobTable_into_oplog\n  AFTER UPDATE ON "public"."blobTable"\n    FOR EACH ROW\n      EXECUTE FUNCTION update_public_blobTable_into_oplog_function();',
      'DROP TRIGGER IF EXISTS delete_public_blobTable_into_oplog ON "public"."blobTable";',
      "CREATE OR REPLACE FUNCTION delete_public_blobTable_into_oplog_function()\n    RETURNS TRIGGER AS \$\$\n    BEGIN\n      DECLARE\n        flag_value INTEGER;\n      BEGIN\n        -- Get the flag value from _electric_trigger_settings\n        SELECT flag INTO flag_value FROM public._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'blobTable';\n\n        IF flag_value = 1 THEN\n          -- Insert into _electric_oplog\n          INSERT INTO public._electric_oplog (namespace, tablename, optype, \"primaryKey\", \"newRow\", \"oldRow\", timestamp)\n          VALUES (\n            'public',\n            'blobTable',\n            'DELETE',\n            json_strip_nulls(json_build_object('value', CASE WHEN old.\"value\" IS NOT NULL THEN encode(old.\"value\"::bytea, 'hex') ELSE NULL END)),\n            NULL,\n            jsonb_build_object('value', CASE WHEN old.\"value\" IS NOT NULL THEN encode(old.\"value\"::bytea, 'hex') ELSE NULL END),\n            NULL\n          );\n        END IF;\n\n        RETURN NEW;\n      END;\n    END;\n    \$\$ LANGUAGE plpgsql;",
      'CREATE TRIGGER delete_public_blobTable_into_oplog\n  AFTER DELETE ON "public"."blobTable"\n    FOR EACH ROW\n      EXECUTE FUNCTION delete_public_blobTable_into_oplog_function();',
    ],
    version: '2',
  ),
];
