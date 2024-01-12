import 'package:electricsql/electricsql.dart';
import 'package:electricsql_cli/src/config.dart';
import 'package:electricsql_cli/src/util.dart';
import 'package:path/path.dart';

const minorVersion = kElectricProtocolVersion;

final configOptions = <String, ConfigOption<Object>>{
    // *** Client options ***

  'SERVICE': ConfigOption<String>(
    valueTypeName: 'url',
    doc: 'URL of the Electric service.',
    groups: ['client', 'tunnel'],
    shortForm: 's',
    defaultValueFun: () {
      final host = getConfigValue<String>('SERVICE_HOST');
      final port = getConfigValue<int>('HTTP_PORT');
      return 'http://$host:$port';
    },
    constructedDefault: 'http://{ELECTRIC_SERVICE_HOST}:{ELECTRIC_HTTP_PORT}',
  ),
  'PROXY': ConfigOption<String>(
    valueTypeName: 'url',
    doc: "URL of the Electric service's PostgreSQL proxy.",
    groups: ['client', 'proxy'],
    shortForm: 'p',
    defaultValueFun: () {
      final host = getConfigValue<String>('SERVICE_HOST');
      final port = getConfigValue<int>('PG_PROXY_PORT');
      final password = getConfigValue<String>('PG_PROXY_PASSWORD');
      final dbName = getConfigValue<String>('DATABASE_NAME');
      return 'postgresql://postgres:$password@$host:$port/$dbName';
    },
    constructedDefault:
        'postgresql://postgres:{ELECTRIC_PG_PROXY_PASSWORD}@{ELECTRIC_SERVICE_HOST}:{ELECTRIC_PG_PROXY_PORT}/{ELECTRIC_DATABASE_NAME}',
  ),
  'CLIENT_PATH': ConfigOption<String>(
    valueTypeName: 'path',
    shortForm: 'o',
    doc: 'Path to the directory where the generated electric client code will be written.',
    groups: ['client'],
    defaultValue: join('.', 'lib', 'generated', 'electric'),
  ),
  'SERVICE_HOST': ConfigOption<String>(
    valueTypeName: 'hostname',
    doc: 'Hostname the Electric service is running on.',
    groups: ['client', 'proxy'],
    defaultValueFun: () => defaultServiceUrlPart('host', 'localhost'),
  ),

  // *** Postgres database connection options ***
  'WITH_POSTGRES': ConfigOption<bool>(
    doc: 'Start a PostgreSQL database along with Electric.',
    defaultValue: false,
    groups: ['database', 'electric'],
  ),
  'DATABASE_URL': ConfigOption<String>(
    doc: 'PostgreSQL connection URL for the database.',
    valueTypeName: 'url',
    shortForm: 'db',
    defaultValueFun: () {
      final host = getConfigValue<String>('DATABASE_HOST');
      final port = getConfigValue<int>('DATABASE_PORT');
      final user = getConfigValue<String>('DATABASE_USER');
      final password = getConfigValue<String>('DATABASE_PASSWORD');
      final dbName = getConfigValue<String>('DATABASE_NAME');
      return buildDatabaseURL(
        host: host,
        port: port,
        user: user,
        password: password,
        dbName: dbName,
      );
    },
    constructedDefault:
        'postgresql://{ELECTRIC_DATABASE_USER}:{ELECTRIC_DATABASE_PASSWORD}@{ELECTRIC_DATABASE_HOST}:{ELECTRIC_DATABASE_PORT}/{ELECTRIC_DATABASE_NAME}',
    groups: ['database', 'electric'],
  ),
  'DATABASE_HOST': ConfigOption<String>(
    doc: 'Hostname of the database server.',
    defaultValueFun: () => defaultDbUrlPart('host', 'localhost'),
    groups: ['database'],
  ),
  'DATABASE_PORT': ConfigOption<int>(
    doc: 'Port number of the database server.',
    defaultValueFun: () => defaultDbUrlPart('port', 5432),
    groups: ['database'],
  ),
  'DATABASE_USER': ConfigOption<String>(
    doc: 'Username to connect to the database with.',
    defaultValueFun: () => defaultDbUrlPart('user', 'postgres'),
    groups: ['database'],
  ),
  'DATABASE_PASSWORD': ConfigOption<String>(
    doc: 'Password to connect to the database with.',
    defaultValueFun: () => defaultDbUrlPart('password', 'db_password'),
    groups: ['database'],
  ),
  'DATABASE_NAME': ConfigOption<String>(
    doc: 'Name of the database to connect to.',
    defaultValueFun: () =>
        defaultDbUrlPart('dbName', getAppName() ?? 'electric'),
    groups: ['database', 'client', 'proxy'],
  ),

  // *** Electric options ***
  'DATABASE_REQUIRE_SSL': ConfigOption<bool>(
    defaultValue: false,
    doc: 'Require SSL for the connection to the database.',
    groups: ['electric'],
  ),
  'DATABASE_USE_IPV6': ConfigOption<bool>(
    defaultValue: false,
    doc:
        'Set if your database is only accessible over IPv6. This is the case with '
        'Fly Postgres, for example.',
    groups: ['electric'],
  ),
  'ELECTRIC_USE_IPV6': ConfigOption<bool>(
    defaultValue: false,
    doc: '''
Make Electric listen on :: instead of 0.0.0.0. On Linux this allows inbound 
connections over both IPv6 and IPv4. On Windows and some BSD systems inbound 
connections will only be accepted over IPv6 when this setting is enabled.''',
    groups: ['electric'],
  ),
  'LOGICAL_PUBLISHER_HOST': ConfigOption<String>(
    valueTypeName: 'url',
    doc:
        'Host of this electric instance for the reverse connection from Postgres.',
    groups: ['electric'],
  ),
  'LOGICAL_PUBLISHER_PORT': ConfigOption<int>(
    defaultValue: 5433,
    valueTypeName: 'port',
    doc: 'Port number to use for reverse connections from Postgres.',
    groups: ['electric'],
  ),
  'HTTP_PORT': ConfigOption<int>(
    defaultValueFun: () => defaultServiceUrlPart('port', 5133),
    valueTypeName: 'port',
    doc: '''
Port for HTTP connections. Includes client websocket connections on /ws, and 
other functions on /api.''',
    groups: ['electric', 'client'],
  ),
  'PG_PROXY_PORT': ConfigOption<int>(
    defaultValue: 65432,
    valueTypeName: 'port',
    doc: 'Port number for connections to the Postgres migration proxy.',
    groups: ['electric', 'client', 'proxy'],
  ),
  'PG_PROXY_PASSWORD': ConfigOption<String>(
    defaultValue: 'proxy_password',
    valueTypeName: 'password',
    doc: 'Password to use when connecting to the Postgres proxy via psql or any other Postgres client.',
    groups: ['electric', 'client', 'proxy'],
  ),
  'AUTH_MODE': ConfigOption<String>(
    defaultValue: 'insecure',
    valueTypeName: 'secure | insecure',
    doc: 'Authentication mode to use to authenticate clients.',
    groups: ['electric'],
  ),
  'AUTH_JWT_ALG': ConfigOption<String>(
    valueTypeName: 'algorithm',
    doc: 'The algorithm to use for JWT verification.',
    groups: ['electric'],
  ),
  'AUTH_JWT_KEY': ConfigOption<String>(
    valueTypeName: 'key',
    doc: 'The key to use for JWT verification',
    groups: ['electric'],
  ),
  'AUTH_JWT_NAMESPACE': ConfigOption<String>(
    valueTypeName: 'namespace',
    doc: '''This is an optional setting that specifies the location inside the token of 
custom claims that are specific to Electric.''',
    groups: ['electric'],
  ),
  'AUTH_JWT_ISS': ConfigOption<String>(
    valueTypeName: 'iss',
    doc: '''This optional setting allows you to specificy the "issuer" that will be matched 
against the iss claim extracted from auth tokens.''',
    groups: ['electric'],
  ),
  'AUTH_JWT_AUD': ConfigOption<String>(
    valueTypeName: 'aud',
    doc: '''This optional setting allows you to specificy the "audience" that will be matched
against the aud claim extracted from auth tokens.''',
    groups: ['electric'],
  ),
  'ELECTRIC_TELEMETRY': ConfigOption<String>(
    defaultValue: 'enabled',
    valueTypeName: 'enabled | disabled',
    doc: 'Set to "disable" to disable sending telemetry data to Electric.',
    groups: ['electric'],
  ),
  'POSTGRESQL_IMAGE': ConfigOption<String>(
    defaultValue: 'postgres:14-alpine',
    valueTypeName: 'image',
    doc: 'The Docker image to use for the PostgreSQL database.',
    groups: ['electric'],
  ),
  'ELECTRIC_IMAGE': ConfigOption<String>(
    defaultValue: 'electricsql/electric:$minorVersion', // Latest minor version of the electric service
    valueTypeName: 'image',
    doc: 'The Docker image to use for Electric.',
    groups: ['electric'],
  ),
};

/*
export const configOptions = {
 
  AUTH_MODE: {
    defaultVal: 'insecure',
    valueType: String,
    valueTypeName: 'secure | insecure',
    doc: 'Authentication mode to use to authenticate clients.',
    groups: ['electric'],
  },
  AUTH_JWT_ALG: {
    valueType: String,
    valueTypeName: 'algorithm',
    doc: 'The algorithm to use for JWT verification.',
    groups: ['electric'],
  },
  AUTH_JWT_KEY: {
    valueType: String,
    valueTypeName: 'key',
    doc: 'The key to use for JWT verification',
    groups: ['electric'],
  },
  AUTH_JWT_NAMESPACE: {
    valueType: String,
    valueTypeName: 'namespace',
    doc: dedent`
      This is an optional setting that specifies the location inside the token of 
      custom claims that are specific to Electric.
    `,
    groups: ['electric'],
  },
  AUTH_JWT_ISS: {
    valueType: String,
    valueTypeName: 'iss',
    doc: dedent`
      This optional setting allows you to specificy the "issuer" that will be matched 
      against the iss claim extracted from auth tokens.
    `,
    groups: ['electric'],
  },
  AUTH_JWT_AUD: {
    valueType: String,
    valueTypeName: 'aud',
    doc: dedent`
      This optional setting allows you to specificy the "audience" that will be matched
      against the aud claim extracted from auth tokens.
    `,
    groups: ['electric'],
  },
  ELECTRIC_TELEMETRY: {
    valueType: String,
    defaultVal: 'enabled',
    valueTypeName: 'enabled | disabled',
    doc: 'Set to "disable" to disable sending telemetry data to Electric.',
    groups: ['electric'],
  },
  POSTGRESQL_IMAGE: {
    valueType: String,
    valueTypeName: 'image',
    defaultVal: 'postgres:14-alpine',
    doc: 'The Docker image to use for the PostgreSQL database.',
    groups: ['electric'],
  },
  ELECTRIC_IMAGE: {
    valueType: String,
    valueTypeName: 'image',
    defaultVal: `electricsql/electric:${minorVersion}`, // Latest minor version of this library
    doc: 'The Docker image to use for Electric.',
    groups: ['electric'],
  },
} as const

*/