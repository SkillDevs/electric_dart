import 'dart:io';

import 'package:dotenv/dotenv.dart';

late DotEnv programEnv;

void loadEnv() {
  programEnv = DotEnv(includePlatformEnvironment: true);

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
  programEnv.load(effectiveFiles);
}
