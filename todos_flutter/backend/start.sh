#!/bin/bash

set -e

source .envrc

# Pull the latest Electric image pinned in the compose file
docker compose pull electric

# Depending the docker version it can be 'docker compose' without the dash
docker compose up