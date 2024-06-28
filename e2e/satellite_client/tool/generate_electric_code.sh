#!/bin/bash

# We spawn a temporary ElectricSQL instance to introspect and generate the E2E client code

set -e

dart run electricsql_cli stop --remove
dart run electricsql_cli start --with-postgres --detach

# {{ELECTRIC_PROXY}} will be replaced automatically with the correct value in the `with-config` command
MIGRATE_COMMAND="dbmate -u {{ELECTRIC_PROXY}} -d db --no-dump-schema up"

# Run the migrations on Postgres
dart run electricsql_cli with-config "$MIGRATE_COMMAND"

# Generate Raw client code
dart run electricsql_cli generate --with-dal=false

# Generate Drift client code
# We want BigInts in E2E, because int8 with regular int is equivalent to
# the int4 test suite
dart run electricsql_cli generate --with-dal=true --int8-as-bigint

dart run electricsql_cli stop --remove
