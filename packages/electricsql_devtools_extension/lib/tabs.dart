// ignore: invalid_use_of_internal_member, implementation_imports
import 'package:electricsql/src/devtools/shared.dart';

class DevToolsDbProps {
  final String dbName;
  final SqlDialect dialect;

  DevToolsDbProps({
    required this.dbName,
    required this.dialect,
  });

  @override
  bool operator ==(covariant DevToolsDbProps other) {
    if (identical(this, other)) return true;

    return other.dbName == dbName && other.dialect == dialect;
  }

  @override
  int get hashCode => dbName.hashCode ^ dialect.hashCode;
}
