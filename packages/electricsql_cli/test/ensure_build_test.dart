@Tags(['version-verify'])
library ensure_build_test;

import 'package:build_verify/build_verify.dart';
import 'package:test/test.dart';

void main() {
  test(
    'ensure_build',
    () =>
        expectBuildClean(packageRelativeDirectory: 'packages/electricsql_cli'),
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
