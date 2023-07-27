import 'dart:ffi';

import 'package:sqlite3/open.dart';

bool done = false;
void setupSqliteOpen() {
  const path = '/home/david/Dev/Flutter/drift/drift/libsqlite3custom.so';
  if (!done) {
    open.overrideForAll(() => DynamicLibrary.open(path));
    done = true;
  }
}
