import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:electricsql_cli/src/commands/command_util.dart';
import 'package:electricsql_cli/src/commands/commands.dart';
import 'package:electricsql_cli/src/config.dart';
import 'package:electricsql_cli/src/exit_signals.dart';
import 'package:electricsql_cli/src/util.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:web_socket_channel/io.dart';

const String defaultElectricServiceWSUrl = 'ws://localhost:5133';
const int defaultLocalPort = 65432;

class ProxyTunnelCommand extends Command<int> {
  ProxyTunnelCommand({
    required Logger logger,
  }) : _logger = logger {
    addOptionGroupToCommand(this, 'tunnel');

    addSpecificOptionsSeparator(this);

    argParser.addOption(
      'local-port',
      help: 'Local port to bind the tunnel to',
      valueHelp: 'port',
      defaultsTo: defaultLocalPort.toString(),
    );
  }

  @override
  String get description =>
      'Open a tunnel to the Electric Postgres Proxy and binds it to a local port';

  @override
  String get name => 'proxy-tunnel';

  final Logger _logger;

  @override
  Future<int> run() async {
    final opts = getOptsFromCommand(this);
    final config = getConfig(opts);
    final localPortParam = opts['local-port']! as String;
    try {
      // port
      final int? finalLocalPort = int.tryParse(localPortParam);
      if (finalLocalPort == null) {
        _logger.err('Invalid local port: $localPortParam');
        throw ConfigException();
      }

      await runProxyTunnel(
        serviceUrl: config.read<String>('SERVICE'),
        localPort: finalLocalPort,
        logger: _logger,
      );
      return ExitCode.success.code;
    } on ConfigException catch (_) {
      return ExitCode.config.code;
    }
  }
}

Future<void> runProxyTunnel({
  required String serviceUrl,
  required int localPort,
  required Logger logger,
}) async {
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, localPort);

  final disposeExitSignals = handleExitSignals(
    onExit: (_) async {
      await server.close();
      return false;
    },
  );

  // Cleanup the service URL
  if (serviceUrl.startsWith('https://')) {
    serviceUrl = serviceUrl.replaceFirst('https://', 'wss://');
  } else if (serviceUrl.startsWith('http://')) {
    serviceUrl = serviceUrl.replaceFirst('http://', 'ws://');
  }
  serviceUrl = removeTrailingSlash(serviceUrl);

  logger.info('ElectricSQL Postgres Proxy Tunnel listening on port $localPort');
  logger.info('Connected to ElectricSQL Service at $serviceUrl');
  logger.info('Connect to the database using:');
  logger.info('  psql -h localhost -p $localPort -U <username> <database>');
  logger.info('Or with the connection string:');
  logger.info(
    '  psql "postgres://<username>:<password>@localhost:$localPort/<database>"',
  );
  logger.info('Press Ctrl+C to exit');
  logger.info('--');

  await for (final client in server) {
    logger.info('New connection!');

    final websocketUrl = '$serviceUrl/proxy';
    final websocket = IOWebSocketChannel.connect(
      websocketUrl,
      protocols: [],
    );
    try {
      await websocket.ready;
    } catch (e) {
      logger.err('Failed to connect to WebSocket at $websocketUrl. Error: $e');
      await client.close();
      continue;
    }

    logger.info('Created WebSocket stream');

    final sub = websocket.stream.listen((dynamic event) {
      client.add(event as List<int>);
    });

    client.listen(
      (event) {
        websocket.sink.add(event);
      },
      onDone: () {
        logger.info('Client disconnected');
        sub.cancel();
        websocket.sink.close();
      },
    );
  }

  await disposeExitSignals();
}
