#!/usr/bin/env bash
set -e

if [ "$1" = 'baresip' ]; then
    echo "called baresip $@"
    /usr/bin/baresip "$@"
else
    echo "called something else"
    exec "$@"
fi