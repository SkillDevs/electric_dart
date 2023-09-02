#!/bin/bash

set -e

source .envrc

# Depending the docker version it can be 'docker compose' without the dash
docker compose up