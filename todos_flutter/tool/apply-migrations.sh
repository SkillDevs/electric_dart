#!/bin/bash

set -e

# {{ELECTRIC_PROXY}} will be replaced automatically with the correct value in the `with-config` command
MIGRATE_COMMAND="dbmate -u {{ELECTRIC_PROXY}} -d db/migrations --no-dump-schema up"

# Runs a command with the correct environment variables set
dart run electricsql_cli with-config "$MIGRATE_COMMAND"
