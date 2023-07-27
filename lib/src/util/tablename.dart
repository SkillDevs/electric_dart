import 'package:equatable/equatable.dart';

class QualifiedTablename with EquatableMixin {
  final String namespace;
  final String tablename;

  const QualifiedTablename(this.namespace, this.tablename);

  @override
  String toString() => '$namespace.$tablename';

  @override
  List<Object?> get props => [namespace, tablename];
}
