#!/bin/bash

set -ex

VERSION=$(yq -r .version pubspec.yaml)

TAG_NAME="electricsql-$VERSION"

rm -rf pubspec_overrides.yaml

dart pub get

dart test

# Build the devtools extension
pushd ../electricsql_devtools_extension
./build.sh
popd

git tag "$TAG_NAME"

dart pub publish

git push origin "$TAG_NAME"

# Restore the overrides
melos bs