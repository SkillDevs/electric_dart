#!/bin/bash

set -ex

rm -rf pubspec_overrides.yaml

dart pub get

dart pub publish

# Restore the overrides
melos bs