import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Mimics ohash from NPM
/// [unordered] Sort all arrays before hashing
String ohashList<T>(
  List<T> list, {
  bool unordered = false,
  required List<Object?> Function(T) getProps,
}) {
  final listStrings =
      list.map((e) => _mapPropsToString(e.runtimeType, getProps(e))).toList();
  if (unordered) {
    listStrings.sort();
  }

  final StringBuffer buf = StringBuffer();
  buf.write('list:${list.length}:');
  for (final s in listStrings) {
    buf.write(s);
    buf.write(',');
  }

  final strBytes = utf8.encode(buf.toString());
  final sha256bytes = sha256.convert(strBytes).bytes;
  final hash = base64.encode(sha256bytes);
  final substr = hash.substring(0, min(10, hash.length));

  // print("HASH: $buf $hash");
  return substr;
}

String _mapPropsToString(Type runtimeType, List<Object?> props) =>
    '$runtimeType(${props.map((prop) => prop.toString()).join(', ')})';
