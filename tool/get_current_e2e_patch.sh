#!/bin/bash

set -e

ROOT_DIR=$(realpath .)
ELECTRIC_REPO_E2E_PATH="$ROOT_DIR"/e2e/electric_repo/e2e
DART_REPO_E2E_PATH="$ROOT_DIR"/e2e

# Set the timezone to UTC to be consistent in the patch file
export TZ=UTC

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
cp -r "$ELECTRIC_REPO_E2E_PATH" electric
cp -r "$DART_REPO_E2E_PATH" dart

# Update the modified date of all files to be diffed, so that the dates remain
# the same in the git history
find . -exec touch -m -d '1/1/2024' {} +

rm "$PATCH_PATH" || true
diff -x "lux" -x "satellite_client" -x "lux_logs" -ur electric dart > "$PATCH_PATH" || true
popd
rm -rf diff
###################################
