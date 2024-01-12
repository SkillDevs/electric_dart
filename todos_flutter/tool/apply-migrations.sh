#!/bin/bash

set -e

MIGRATE_COMMAND="dbmate -u {{ELECTRIC_PROXY}}?sslmode=disable -d backend/migrations --no-dump-schema up"

dart run electricsql_cli with-config "$MIGRATE_COMMAND"
