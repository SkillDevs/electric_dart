#!/bin/bash

# Show commit messages from the Electric repository.
# Used to include the original commit messages from the Electric repo when the Dart client is updated.
# Example usage: tool/upstream_git_log.sh 123abc..HEAD

set -e

ELECTRIC_REPO='../electric'

pushd "$ELECTRIC_REPO"

COMMIT_FORMAT='%h - %s%n%ad - %an%nhttps://github.com/electric-sql/electric/commit/%h%n'

INTERESTING_FILES=(
  'clients/typescript'
  'components/toolbar'
  'e2e'
)

TZ=UTC0 git --no-pager log --reverse --pretty=format:"$COMMIT_FORMAT" --date=iso-local "$@" -- "${INTERESTING_FILES[@]}"
