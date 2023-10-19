import 'dart:ffi';
import 'dart:io';

import 'package:satellite_dart_client/cli/prompt.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

Future<void> main(List<String> arguments) async {
  open.overrideFor(OperatingSystem.linux, _openOnLinux);

  await start();
}

DynamicLibrary _openOnLinux() {
  const usrLocalLib = '/usr/local/lib/libsqlite3.so';
  if (File(usrLocalLib).existsSync()) {
    return DynamicLibrary.open(usrLocalLib);
  }
  return DynamicLibrary.open('libsqlite3.so.0');
}
