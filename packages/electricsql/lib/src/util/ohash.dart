import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class OhashOpts {
  /// [unordered] Sort all arrays before hashing
  final bool unorderedLists;

  const OhashOpts({
    this.unorderedLists = false,
  });

  OhashOpts copyWith({
    bool? unorderedLists,
  }) {
    return OhashOpts(
      unorderedLists: unorderedLists ?? this.unorderedLists,
    );
  }
}

/// Mimics ohash from NPM
String ohash(Object? obj, {OhashOpts? opts}) {
  final effectiveOpts = opts ?? const OhashOpts();
  final buf = StringBuffer();
  _writeHash(obj, effectiveOpts, buf);
  final hashStr = buf.toString();

  // Compute hash
  final strBytes = utf8.encode(hashStr);
  final sha256bytes = sha256.convert(strBytes).bytes;
  final hash = base64.encode(sha256bytes);
  final substr = hash.substring(0, min(10, hash.length));

  // print("HASH: $obj -> $hashStr -> $hash");
  return substr;
}

void _writeHash(Object? obj, OhashOpts opts, StringBuffer buf) {
  if (obj == null) {
    buf.write('null');
  } else if (obj is String) {
    buf.write('string:${obj.length}:$obj');
  } else if (obj is bool) {
    buf.write('bool:$obj');
  } else if (obj is num) {
    buf.write('num:$obj');
  } else if (obj is List) {
    buf.write('list:${obj.length}:');
    if (!opts.unorderedLists) {
      for (final e in obj) {
        _writeHash(e, opts, buf);
      }
    } else {
      // Sort entries
      final entries = obj.map((e) {
        final nestedBuf = StringBuffer();
        _writeHash(e, opts.copyWith(unorderedLists: false), nestedBuf);
        return nestedBuf.toString();
      }).toList();

      entries.sort();

      for (final entry in entries) {
        buf.write(entry);
      }
    }
  } else if (obj is Map) {
    buf.write('map:${obj.length}:');
    for (final entry in obj.entries) {
      _writeHash(entry.key, opts, buf);
      buf.write(':');
      _writeHash(entry.value, opts, buf);
      buf.write(',');
    }
  } else {
    throw UnimplementedError();
  }
}
