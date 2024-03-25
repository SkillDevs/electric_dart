// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: depend_on_referenced_packages, prefer_double_quotes

import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';

const kElectrifiedTables = [
  Todo,
  Todolist,
];

class Todo extends Table {
  TextColumn get id => text().named('id')();

  TextColumn get listid => text().named('listid').nullable()();

  TextColumn get text$ => text().named('text').nullable()();

  BoolColumn get completed => boolean().named('completed')();

  Column<DateTime> get editedAt =>
      customType(ElectricTypes.timestampTZ).named('edited_at')();

  @override
  String? get tableName => 'todo';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

class Todolist extends Table {
  TextColumn get id => text().named('id')();

  TextColumn get filter => text().named('filter').nullable()();

  TextColumn get editing => text().named('editing').nullable()();

  @override
  String? get tableName => 'todolist';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}
