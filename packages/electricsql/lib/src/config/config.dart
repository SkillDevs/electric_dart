import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/util/debug/debug.dart';

class ElectricConfig {
  /// Optional authentication configuration.
  /// If not provided, a client ID is generated.
  final AuthConfig? auth;

  /// Optional URL string to connect to the Electric sync service.
  ///
  /// Should have the following format:
  /// `protocol://<host>:<port>[?ssl=true]`
  ///
  /// If the protocol is `https` or `wss` then `ssl`
  /// defaults to true. Otherwise it defaults to false.
  ///
  /// If port is not provided, defaults to 443 when
  /// ssl is enabled or 80 when it isn't.
  ///
  /// Defaults to:
  /// `http://localhost:5133`
  final String? url;

  /// Optional logger configuration.
  final LoggerConfig? logger;

  /// Timeout for RPC requests.
  /// Needs to be large enough for the server to have time to deliver the full initial subscription data
  /// when the client subscribes to a shape for the first time.
  final Duration? timeout;

  /// Optional backoff options for connecting with Electric
  final ConnectionBackoffOptions? connectionBackoffOptions;

  ElectricConfig({
    this.auth,
    this.url,
    this.logger,
    this.timeout,
    this.connectionBackoffOptions,
  });
}

class HydratedConfig {
  final AuthConfig auth;
  final ReplicationConfig replication;
  final ConnectionBackoffOptions connectionBackoffOptions;

  HydratedConfig({
    required this.auth,
    required this.replication,
    required this.connectionBackoffOptions,
  });
}

class ReplicationConfig {
  final String host;
  final int port;
  final bool ssl;
  final Duration timeout;

  ReplicationConfig({
    required this.host,
    required this.port,
    required this.ssl,
    required this.timeout,
  });
}

HydratedConfig hydrateConfig(ElectricConfig config) {
  final auth = config.auth ?? const AuthConfig();

  //final debug = config.debug ?? false;

  final parsedServiceUrl = _parseServiceUrl(config.url);

  final replication = ReplicationConfig(
    host: parsedServiceUrl.hostname,
    port: parsedServiceUrl.port,
    ssl: parsedServiceUrl.ssl,
    timeout: config.timeout ?? const Duration(milliseconds: 3000),
  );

  final connectionBackoffOptions = config.connectionBackoffOptions ??
      kSatelliteDefaults.connectionBackoffOptions;

  return HydratedConfig(
    auth: auth,
    replication: replication,
    //debug: debug,
    connectionBackoffOptions: connectionBackoffOptions,
  );
}

({String hostname, int port, bool ssl}) _parseServiceUrl(String? inputUrl) {
  final Uri uri;
  try {
    uri = Uri.parse(inputUrl ?? 'http://localhost:5133');
    if (uri.host.isEmpty) {
      throw Exception('Missing host');
    }
  } catch (e) {
    _throwInvalidServiceUrlError();
  }

  final warnings = <String>[];
  //const expectedProtocols = {'http', 'https', 'ws', 'wss', 'electric'};

  // Detect if the user has provided a postgres URL by mistake.
  if ({'postgres', 'postgresql'}.contains(uri.scheme)) {
    warnings.add('Unsupported URL protocol.');
  }

  /* if (!expectedProtocols.contains(uri.scheme)) {
    warnings.add('Unsupported URL protocol.');
  }

  if (uri.userInfo.isNotEmpty) {
    warnings.add('Username and password are not supported.');
  }

  if (uri.path != '/' && uri.path != '') {
    warnings.add('An URL path is not supported.');
  }
 */
  final isSecureProtocol = uri.scheme == 'https' || uri.scheme == 'wss';
  final sslEnabled = isSecureProtocol || uri.queryParameters['ssl'] == 'true';

  final defaultPort = sslEnabled ? 443 : 80;
  final port = uri.hasPort ? uri.port : defaultPort;

  if (warnings.isNotEmpty) {
    _warnUnexpectedServiceUrl(warnings);
  }

  return (hostname: uri.host, port: port, ssl: sslEnabled);
}

Never _throwInvalidServiceUrlError([String? reason]) {
  String msg = "Invalid 'url' in the configuration.";
  if (reason != null) {
    msg += ' $reason';
  }
  throw Exception(msg);
}

void _warnUnexpectedServiceUrl(List<String> reasons) {
  String msg = "Unexpected 'url' in the configuration.";

  if (reasons.isNotEmpty) {
    msg += ' ${reasons.join(' ')}';
  }

  msg += " An URL like 'http(s)://<host>:<port>' is expected.";
  logger.warning(msg);
}
