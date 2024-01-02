import 'dart:io';
import 'dart:isolate';

import 'package:embed_annotation/embed_annotation.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as path;

part 'assets.g.dart';

const _kRootAssetPath = '../../assets';

@EmbedStr('$_kRootAssetPath/docker/compose.yaml')
const kComposeYaml = _$kComposeYaml;

@EmbedStr('$_kRootAssetPath/docker/compose-base.yaml')
const kComposeBaseYaml = _$kComposeBaseYaml;

@EmbedStr('$_kRootAssetPath/docker/postgres.conf')
const kPostgresConf = _$kPostgresConf;

Future<Directory> getElectricCLIAssetsDir() async {
  final pkgConfigUri = await Isolate.packageConfig;

  final pkgConfig = await loadPackageConfigUri(pkgConfigUri!);
  final cliSrcUri = pkgConfig.packages
      .where((pkg) => pkg.name == 'electricsql_cli')
      .map((e) => e.packageUriRoot)
      .first;
  final cliRootDir =
      Directory(cliSrcUri.toFilePath(windows: Platform.isWindows));

  return Directory(path.join(cliRootDir.path, 'assets'));
}
