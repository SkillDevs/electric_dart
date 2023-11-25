String valueToPrettyStr(Object? value) {
  if (value is Map<String, Object?>) {
    return mapToPrettyStr(value);
  } else if (value is List<Object?>) {
    return listToPrettyStr(value, withNewLine: false);
  } else {
    return value.toString();
  }
}

String listToPrettyStr(List<Object?> list, {required bool withNewLine}) {
  if (list.isEmpty) {
    return "[]";
  }

  final buffer = StringBuffer();
  buffer.write("[");
  if (withNewLine) {
    buffer.writeln();
  }

  int i = 0;
  for (final value in list) {
    if (withNewLine) {
      // tab
      buffer.write(" ");
    }

    buffer.write(" ");
    buffer.write(valueToPrettyStr(_getDistinctiveValue(value)));

    if (withNewLine || i != list.length - 1) {
      buffer.write(",");
    }

    if (withNewLine) {
      buffer.writeln();
    }

    i++;
  }

  if (!withNewLine) {
    buffer.write(" ");
  }

  buffer.write("]");

  if (withNewLine) {
    buffer.writeln();
  }

  return buffer.toString();
}

String mapToPrettyStr(Map<String, Object?> row) {
  if (row.isEmpty) {
    return "{}";
  }

  final buffer = StringBuffer();
  buffer.write("{ ");
  final entries = row.entries.toList();
  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    final value = entry.value;

    final valueStr = valueToPrettyStr(_getDistinctiveValue(value));

    buffer.write("${entry.key}: $valueStr");

    if (i != entries.length - 1) {
      buffer.write(", ");
    }
  }
  buffer.write(" }");
  return buffer.toString();
}

Object? _getDistinctiveValue(Object? value) {
  if (value is String) {
    final quote = value.contains("'") ? '"' : "'";
    return "$quote$value$quote";
  } else {
    return value;
  }
}
