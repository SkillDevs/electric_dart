import 'dart:convert';

import 'package:equatable/equatable.dart';

class QualifiedTablename with EquatableMixin {
  final String namespace;
  final String tablename;

  const QualifiedTablename(this.namespace, this.tablename);

  @override
  String toString() {
    // Escapes double quotes because names can contain double quotes
    // e.g. CREATE TABLE "f""oo" (...) creates a table named f"oo
    return '"${escDoubleQ(namespace)}"."${escDoubleQ(tablename)}"';
  }

  @override
  List<Object?> get props => [namespace, tablename];

  static QualifiedTablename parse(String fullyQualifiedName) {
    try {
      // allow only paired double quotes within the quotes
      // identifiers can't be empty
      final regex = RegExp(r'^"((?:[^"]|"")+)"\."((?:[^"]|"")+)"$');

      final match = regex.firstMatch(fullyQualifiedName)!;
      final namespace = match.group(1)!;
      final tablename = match.group(2)!;

      return QualifiedTablename(
        unescDoubleQ(namespace),
        unescDoubleQ(tablename),
      );
    } catch (_e) {
      throw Exception(
        'Could not parse string into a qualified table name: $fullyQualifiedName',
      );
    }
  }
}

String escDoubleQ(String str) {
  return str.replaceAll('"', '""');
}

String unescDoubleQ(String str) {
  return str.replaceAll('""', '"');
}
