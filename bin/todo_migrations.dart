import 'package:electric_client/migrators/migrators.dart';

final todoMigrations = [
  Migration(
    name: "20230124_160941_413_init",
    satelliteBody: [],
    sha256: "01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b",
    title: "init",
    encoding: null,
  ),
  Migration(
    encoding: null,
    name: "20230124_160958_566_create_todomvc_schema",
    satelliteBody: [
      "CREATE TABLE \"todolist\" (\n    \"id\" TEXT NOT NULL,\n    \"filter\" TEXT,\n    \"editing\" TEXT,\n    PRIMARY KEY (\"id\")\n) WITHOUT ROWID;",
      "CREATE TABLE \"todo\" (\n    \"id\" TEXT NOT NULL,\n    \"listid\" TEXT,\n    \"text\" TEXT,\n    \"completed\" INTEGER DEFAULT 0 NOT NULL,\n    PRIMARY KEY (\"id\")\n  ) WITHOUT ROWID;",
      "DROP TABLE IF EXISTS _electric_trigger_settings;",
      "CREATE TABLE _electric_trigger_settings(tablename STRING PRIMARY KEY, flag INTEGER);",
      "INSERT INTO _electric_trigger_settings(tablename,flag) VALUES ('main.todo', 1);",
      "INSERT INTO _electric_trigger_settings(tablename,flag) VALUES ('main.todolist', 1);",
      "DROP TRIGGER IF EXISTS update_ensure_main_todo_primarykey;",
      "CREATE TRIGGER update_ensure_main_todo_primarykey\n   BEFORE UPDATE ON main.todo\nBEGIN\n  SELECT\n    CASE\n      WHEN old.id != new.id THEN\n        RAISE (ABORT,'cannot change the value of column id as it belongs to the primary key')\n    END;\nEND;",
      "DROP TRIGGER IF EXISTS insert_main_todo_into_oplog;",
      "CREATE TRIGGER insert_main_todo_into_oplog\n   AFTER INSERT ON main.todo\n   WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == 'main.todo')\nBEGIN\n  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n  VALUES ('main', 'todo', 'INSERT', json_object('id', new.id), json_object('id', new.id, 'listid', new.listid, 'text', new.text, 'completed', new.completed), NULL, NULL);\nEND;",
      "DROP TRIGGER IF EXISTS update_main_todo_into_oplog;",
      "CREATE TRIGGER update_main_todo_into_oplog\n   AFTER UPDATE ON main.todo\n   WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == 'main.todo')\nBEGIN\n  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n  VALUES ('main', 'todo', 'UPDATE', json_object('id', new.id), json_object('id', new.id, 'listid', new.listid, 'text', new.text, 'completed', new.completed), json_object('id', old.id, 'listid', old.listid, 'text', old.text, 'completed', old.completed), NULL);\nEND;",
      "DROP TRIGGER IF EXISTS delete_main_todo_into_oplog;",
      "CREATE TRIGGER delete_main_todo_into_oplog\n   AFTER DELETE ON main.todo\n   WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == 'main.todo')\nBEGIN\n  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n  VALUES ('main', 'todo', 'DELETE', json_object('id', old.id), NULL, json_object('id', old.id, 'listid', old.listid, 'text', old.text, 'completed', old.completed), NULL);\nEND;",
      "DROP TRIGGER IF EXISTS update_ensure_main_todolist_primarykey;",
      "CREATE TRIGGER update_ensure_main_todolist_primarykey\n   BEFORE UPDATE ON main.todolist\nBEGIN\n  SELECT\n    CASE\n      WHEN old.id != new.id THEN\n        RAISE (ABORT,'cannot change the value of column id as it belongs to the primary key')\n    END;\nEND;",
      "DROP TRIGGER IF EXISTS insert_main_todolist_into_oplog;",
      "CREATE TRIGGER insert_main_todolist_into_oplog\n   AFTER INSERT ON main.todolist\n   WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == 'main.todolist')\nBEGIN\n  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n  VALUES ('main', 'todolist', 'INSERT', json_object('id', new.id), json_object('id', new.id, 'filter', new.filter, 'editing', new.editing), NULL, NULL);\nEND;",
      "DROP TRIGGER IF EXISTS update_main_todolist_into_oplog;",
      "CREATE TRIGGER update_main_todolist_into_oplog\n   AFTER UPDATE ON main.todolist\n   WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == 'main.todolist')\nBEGIN\n  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n  VALUES ('main', 'todolist', 'UPDATE', json_object('id', new.id), json_object('id', new.id, 'filter', new.filter, 'editing', new.editing), json_object('id', old.id, 'filter', old.filter, 'editing', old.editing), NULL);\nEND;",
      "DROP TRIGGER IF EXISTS delete_main_todolist_into_oplog;",
      "CREATE TRIGGER delete_main_todolist_into_oplog\n   AFTER DELETE ON main.todolist\n   WHEN 1 == (SELECT flag from _electric_trigger_settings WHERE tablename == 'main.todolist')\nBEGIN\n  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)\n  VALUES ('main', 'todolist', 'DELETE', json_object('id', old.id), NULL, json_object('id', old.id, 'filter', old.filter, 'editing', old.editing), NULL);\nEND;"
    ],
    sha256: "93193dbaae0539a71847187e38a1240e3888512c1bf833381d0252eb68702f9d",
    title: "create todoMVC schema",
  ),
];
