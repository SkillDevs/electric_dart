import 'dart:io';
import 'dart:isolate';

import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as path;

Future<Directory> getElectricCLIAssetsDir() async {
  final pkgConfigUri = await Isolate.packageConfig;

  final pkgConfig = await loadPackageConfigUri(pkgConfigUri!);
  final cliSrcUri = pkgConfig.packages
      .where((pkg) => pkg.name == 'electricsql_cli')
      .map((e) => e.packageUriRoot)
      .first;
  final cliLibDir = Directory(cliSrcUri.toFilePath());

  final cliRootDir = cliLibDir.parent;

  return Directory(path.join(cliRootDir.path, 'assets'));
}
