#!/bin/bash

echo "$1" > "$2"
shift 2

exec /tools.bash "$@"
