// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_use_package_imports, depend_on_referenced_packages
// ignore_for_file: prefer_double_quotes

import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';

import './migrations.dart';
import './pg_migrations.dart';

const kElectricMigrations = ElectricMigrations(
  sqliteMigrations: kSqliteMigrations,
  pgMigrations: kPostgresMigrations,
);
const kElectrifiedTables = [
  Todo,
  Todolist,
];

class Todo extends Table with ElectricTableMixin {
  TextColumn get id => text().named('id')();

  TextColumn get listid => text().named('listid').nullable()();

  TextColumn get text$ => text().named('text').nullable()();

  BoolColumn get completed => boolean().named('completed')();

  Column<DateTime> get editedAt =>
      customType(ElectricTypes.timestampTZ).named('edited_at')();

  Column<DateTime> get createdAt =>
      customType(ElectricTypes.timestampTZ).named('created_at')();

  @override
  String? get tableName => 'todo';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;

  @override
  $TodoTableRelations get $relations => const $TodoTableRelations();
}

class Todolist extends Table with ElectricTableMixin {
  TextColumn get id => text().named('id')();

  TextColumn get filter => text().named('filter').nullable()();

  TextColumn get editing => text().named('editing').nullable()();

  @override
  String? get tableName => 'todolist';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;

  @override
  $TodolistTableRelations get $relations => const $TodolistTableRelations();
}

// ------------------------------ RELATIONS ------------------------------

class $TodoTableRelations implements TableRelations {
  const $TodoTableRelations();

  TableRelation<Todolist> get todolist => const TableRelation<Todolist>(
        fromField: 'listid',
        toField: 'id',
        relationName: 'TodoToTodolist',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [todolist];
}

class $TodolistTableRelations implements TableRelations {
  const $TodolistTableRelations();

  TableRelation<Todo> get todo => const TableRelation<Todo>(
        fromField: '',
        toField: '',
        relationName: 'TodoToTodolist',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [todo];
}
