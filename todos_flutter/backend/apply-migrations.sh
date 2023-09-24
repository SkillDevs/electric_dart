#!/bin/bash

set -e

source .envrc

if [ -z "$APP_NAME" ]
then
    echo "\$APP_NAME variable not set"
    exit 1
fi

POSTGRES_CONN="postgresql://postgres:password@localhost:5434/${APP_NAME}?sslmode=disable"

dbmate -u "${POSTGRES_CONN}" -d migrations --no-dump-schema up
