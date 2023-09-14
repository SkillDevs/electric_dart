#!/bin/sh

set -e

ELECTRIC_REPO_E2E_PATH=e2e/electric_repo/e2e
DART_REPO_E2E_PATH=e2e

diff -x "lux" -ur "${ELECTRIC_REPO_E2E_PATH}" "${DART_REPO_E2E_PATH}" > dart_e2e.diff