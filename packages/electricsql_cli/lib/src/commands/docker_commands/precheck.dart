import 'dart:io';

int _kMinimumDockerVersion = 23;

Future<CheckDockerRes> checkValidDockerVersion({String? installReason}) async {
  final dockerVersionRes = await Process.run(
    'docker',
    ['version', '--format', '{{.Client.Version}}'],
  );
  if (dockerVersionRes.exitCode != 0) {
    final String reason = installReason ??
        'Docker is not installed. Version $_kMinimumDockerVersion or greater is required';
    return CheckDockerRes(
      errorReason: reason,
    );
  }

  final dockerVersionStr = dockerVersionRes.stdout.toString().trim();
  final int dockerMajorVersion = int.parse(dockerVersionStr.split('.').first);
  if (dockerMajorVersion < _kMinimumDockerVersion) {
    return CheckDockerRes(
      errorReason:
          'Docker version $_kMinimumDockerVersion or greater is required',
    );
  }

  return const CheckDockerRes(errorReason: null);
}

class CheckDockerRes {
  final String? errorReason;

  const CheckDockerRes({required this.errorReason});
}
