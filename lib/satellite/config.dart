class SatelliteConfig {
  final String app;
  final String env;

  SatelliteConfig({required this.app, required this.env});
}

class SatelliteClientOpts {
  final String host;
  final int port;
  final bool ssl;
  final int? timeout;
  final int? pushPeriod;

  SatelliteClientOpts({
    required this.host,
    required this.port,
    required this.ssl,
    this.timeout,
    this.pushPeriod,
  });
}
