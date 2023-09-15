#!/bin/bash

# Extracts the Electric repo commit from which this is based on 
# The README.md contains a line like:
# * Commit: `<some commit>`

COMMIT=$(cat README.md | grep -oE 'Commit: `([0-9a-fA-F]+)`' | sed -E 's/Commit: `(.*)`/\1/')

echo "$COMMIT"