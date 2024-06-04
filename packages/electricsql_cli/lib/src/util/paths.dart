import 'dart:io';

import 'package:path/path.dart';

/// Path where the user ran the CLI
final kAppRootDir = Directory.current.absolute;

/// Path to the pubspec.yaml file in the user's project
final kAppPubspecFile = File(join(kAppRootDir.path, 'pubspec.yaml'));
final kAppPubspecLockFile = File(join(kAppRootDir.path, 'pubspec.lock'));
