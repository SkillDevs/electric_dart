#!/bin/sh

set -e

ROOT_DIR=$(realpath .)
ELECTRIC_REPO_E2E_PATH="$ROOT_DIR"/e2e/electric_repo/e2e
DART_REPO_E2E_PATH="$ROOT_DIR"/e2e

ELECTRIC_COMMIT=$(tool/extract_electric_commit.sh)

echo "Electric commit: $ELECTRIC_COMMIT"

pushd "$DART_REPO_E2E_PATH"
make clone_electric
popd

#### Create diff of e2e files #####
rm -rf diff
mkdir diff

PATCH_PATH="$ROOT_DIR"/patch/e2e.patch

pushd diff
ln -s "$ELECTRIC_REPO_E2E_PATH" electric
ln -s "$DART_REPO_E2E_PATH" dart

rm "$PATCH_PATH" || true
diff -x "lux" -ur electric dart > "$PATCH_PATH" || true
popd
rm -rf diff
###################################
