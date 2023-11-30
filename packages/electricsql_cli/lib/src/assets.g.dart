// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

// **************************************************************************
// StrEmbeddingGenerator
// **************************************************************************

const _$kComposeYaml = r'''
version: '3.8'

configs:
  postgres_config:
    file: './postgres.conf'

volumes:
  pg_data:

services:
  postgres:
    profiles: ['with-postgres']
    image: '${POSTGRESQL_IMAGE:-postgres:14-alpine}'
    environment:
      POSTGRES_DB: ${APP_NAME:-electric}
      POSTGRES_USER: ${DATABASE_USER:-postgres}
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD:-db_password}
    command:
      - -c
      - config_file=/etc/postgresql.conf
    configs:
      - source: postgres_config
        target: /etc/postgresql.conf
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U ${DATABASE_USER:-postgres}']
    extra_hosts:
      - 'host.docker.internal:host-gateway'
    ports:
      - ${DATABASE_PORT:-5432}:5432
    volumes:
      - pg_data:/var/lib/postgresql/data

  electric:
    extends:
      file: compose-base.yaml
      service: ${COMPOSE_ELECTRIC_SERVICE:-electric-no-postgres}

''';

const _$kComposeBaseYaml = r'''
version: '3.8'

services:
  electric-no-postgres:
    image: '${ELECTRIC_IMAGE:-electricsql/electric:latest}'
    init: true
    ports:
      - ${HTTP_PORT:-5133}:${HTTP_PORT:-5133}
      - ${PG_PROXY_PORT:-65432}:${PG_PROXY_PORT:-65432}
    environment:
      DATABASE_REQUIRE_SSL: ${DATABASE_REQUIRE_SSL:-}
      DATABASE_URL: ${DATABASE_URL:-}
      DATABASE_USE_IPV6: ${DATABASE_USE_IPV6:-}
      ELECTRIC_USE_IPV6: ${ELECTRIC_USE_IPV6:-}
      HTTP_PORT: ${HTTP_PORT:-5133}
      LOGICAL_PUBLISHER_HOST: ${LOGICAL_PUBLISHER_HOST:-}
      LOGICAL_PUBLISHER_PORT: ${LOGICAL_PUBLISHER_PORT:-5433}
      PG_PROXY_PASSWORD: ${PG_PROXY_PASSWORD:-proxy_password}
      PG_PROXY_PORT: ${PG_PROXY_PORT:-65432}
      AUTH_MODE: ${AUTH_MODE:-insecure}
      AUTH_JWT_ALG: ${AUTH_JWT_ALG:-}
      AUTH_JWT_AUD: ${AUTH_JWT_AUD:-}
      AUTH_JWT_ISS: ${AUTH_JWT_ISS:-}
      AUTH_JWT_KEY: ${AUTH_JWT_KEY:-}
      AUTH_JWT_NAMESPACE: ${AUTH_JWT_NAMESPACE:-}

  electric-with-postgres:
    extends:
      service: electric-no-postgres
    depends_on:
      - postgres

''';

const _$kPostgresConf = r'''
listen_addresses = '*'
wal_level = 'logical'
# log_min_messages = 'debug1'
# log_min_error_statement = 'debug1'
''';
