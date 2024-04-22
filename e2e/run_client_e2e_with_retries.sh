#!/bin/sh

set -x

ATTEMPTS=3
MAKE_COMMAND=test_client_only

for i in $(seq 1 $ATTEMPTS); do
    echo "Attempt $i"

    if [ "$i" -eq 1 ]; then
        make $MAKE_COMMAND
    else
        TEST="--rerun=fail" make test_only_custom
    fi

    if [ $? -eq 0 ]; then
        echo "Success"
        exit 0
    fi

done

echo "Failed after $ATTEMPTS attempts"
exit 1
