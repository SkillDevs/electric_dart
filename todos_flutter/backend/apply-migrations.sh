#!/bin/bash

set -e

source .envrc

if [ -z "$APP_NAME" ]
then
    echo "\$APP_NAME variable not set"
    exit 1
fi

POSTGRES_CONN="postgresql://postgres:password@localhost:5432/${APP_NAME}?sslmode=disable"

migrate -path migrations -database "${POSTGRES_CONN}" up