import 'dart:io';

import 'package:dotenv/dotenv.dart';

DotEnv? _cachedProgramEnv;

DotEnv get programEnv {
  if (_cachedProgramEnv == null) {
    final env = _loadEnv();
    _cachedProgramEnv = env;
  }
  return _cachedProgramEnv!;
}

DotEnv _loadEnv() {
  final envFiles = <String>[
    '.env',
    '.env.local',
  ];

  final cliEnv = Platform.environment['CLI_ENV']?.trim();
  if (cliEnv != null && cliEnv.isNotEmpty) {
    envFiles.addAll([
      '.env.$cliEnv',
      '.env.$cliEnv.local',
    ]);
  }

  final effectiveFiles = envFiles.where((file) => File(file).existsSync());
  final dotEnv = DotEnv(includePlatformEnvironment: true);
  dotEnv.load(effectiveFiles);

  return dotEnv;
}
