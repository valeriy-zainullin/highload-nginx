#!/bin/bash

cols="$1"
shift 1

echo curl -s -S --fail-with-body "$@"

# https://superuser.com/a/1626376
curl_output=$(curl -s -S --fail-with-body "$@")
if [ "$?" -ne 0 ]; then
    echo -ne "\e[91m"
    echo "$curl_output"
    echo -ne "\e[39m"
    exit 1
else
    echo -ne "\e[36m"
    echo "$curl_output" | head -c$((2*cols))
    echo -ne "\e[39m"
fi
