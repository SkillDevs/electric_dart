import 'dart:convert';

import 'package:electricsql/electricsql.dart';

String electricConfigToJson(ElectricConfig config) {
  final map = {
    "url": config.url,
    "logger": _loggerToMap(config.logger),
    "auth": _authToMap(config.auth),
  };

  return json.encode(map);
}

Map<String, Object?> _loggerToMap(LoggerConfig? logger) {
  if (logger == null) return {};

  return {
    "level": logger.level.toString(),
  };
}

Map<String, Object?> _authToMap(AuthConfig auth) {
  return {
    "token": auth.token,
  };
}

List<Migration> migrationsFromJson(List<dynamic> migrationsJ) {
  return migrationsJ.map((m) => _migrationFromJson(m)).toList();
}

Migration _migrationFromJson(Map<String, Object?> m) {
  final statements =
      (m["statements"] as List<Object?>).map((s) => s as String).toList();
  final version = m["version"] as String;

  return Migration(
    statements: statements,
    version: version,
  );
}
