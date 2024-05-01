import 'dart:convert';

import 'package:equatable/equatable.dart';

class QualifiedTablename with EquatableMixin {
  final String namespace;
  final String tablename;

  const QualifiedTablename(this.namespace, this.tablename);

  @override
  String toString() {
    // Don't collapse it to '<namespace>.<tablename>' because that can lead to clashes
    // since both `QualifiedTablename('foo', 'bar.baz')` and `QualifiedTablename('foo.bar', 'baz')`
    // would be collapsed to 'foo.bar.baz'.
    return json.encode({
      'namespace': namespace,
      'tablename': tablename,
    });
  }

  @override
  List<Object?> get props => [namespace, tablename];

  static QualifiedTablename parse(String jString) {
    try {
      final j = json.decode(jString) as Map<String, dynamic>;
      return QualifiedTablename(
        j['namespace']! as String,
        j['tablename']! as String,
      );
    } catch (_e) {
      throw Exception(
        'Could not parse string into a qualified table name: $jString',
      );
    }
  }
}
