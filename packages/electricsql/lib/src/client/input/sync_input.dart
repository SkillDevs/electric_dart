class SyncInputRaw {
  final String tableName;
  final List<IncludeRelRaw>? include;
  final Map<String, Object?>? where;

  SyncInputRaw({required this.tableName, this.include, this.where});
}

class IncludeRelRaw {
  final List<String> foreignKey;
  final SyncInputRaw select;

  IncludeRelRaw({
    required this.foreignKey,
    required this.select,
  });
}
