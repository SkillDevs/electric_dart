// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: depend_on_referenced_packages, prefer_double_quotes

import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';

const kElectrifiedTables = [
  Todo,
  Todolist,
];

class Todo extends Table {
  TextColumn get id => text()();

  TextColumn get listid => text().nullable()();

  TextColumn get text$ => text().named('text').nullable()();

  BoolColumn get completed => boolean()();

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
  TextColumn get id => text()();

  TextColumn get filter => text().nullable()();

  TextColumn get editing => text().nullable()();

  @override
  String? get tableName => 'todolist';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}
