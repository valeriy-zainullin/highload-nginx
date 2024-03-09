#!/bin/bash

stderr_tmp=$(mktemp)

do_curl_request() {
  cols=$(stty size | tr ' ' '\n' | tail -n1)

  # We need such a hack with while read, because output of
  #   the pipes may not end with a newline, but we need
  #   one for the output to not stack to the output of
  #   the commands in future.
  #   The reason is that head may trim the output in a way
  #   that there won't be a newline in the end. The output
  #   will be stacked..
  # (docker-compose run --rm -T tools "$@" 2>&1; exit 1) | grep -v 'Creating' | \
  #   head -c$((3*cols)) | \
  #   while IFS=$'\n' read -r line || [ -n "$line" ]; do echo "$line"; done

  if ! (
    docker-compose run --rm -T tools \
      /do_curl_request.bash "$cols" "$@" \
      2> "$stderr_tmp"
  ); then
    cat "$stderr_tmp"
    exit 1
  fi
}

# Check benchmark-1.

do_curl_request http://backend-instance-1.benchmark-1/what-date-is-it
do_curl_request http://backend-instance-2.benchmark-1/what-date-is-it
do_curl_request http://nginx-setup-1.benchmark-1/what-date-is-it
do_curl_request http://nginx-setup-2.benchmark-1/what-date-is-it
do_curl_request http://nginx-setup-3.benchmark-1/what-date-is-it
do_curl_request http://nginx-setup-2-withcache.benchmark-1/what-date-is-it

do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://backend-instance-1.benchmark-1/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://backend-instance-2.benchmark-1/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://nginx-setup-1.benchmark-1/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://nginx-setup-2.benchmark-1/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://nginx-setup-3.benchmark-1/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://nginx-setup-2-withcache.benchmark-1/what-is-my-name


# Check benchmark-2.

do_curl_request http://backend-instance-1.benchmark-2/what-date-is-it
do_curl_request http://backend-instance-2.benchmark-2/what-date-is-it
do_curl_request http://backend-instance-3.benchmark-2/what-date-is-it
do_curl_request http://nginx-setup-1.benchmark-2/what-date-is-it
do_curl_request http://nginx-setup-2.benchmark-2/what-date-is-it
do_curl_request http://nginx-setup-3.benchmark-2/what-date-is-it
do_curl_request http://nginx-setup-2-withcache.benchmark-2/what-date-is-it

do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://backend-instance-1.benchmark-2/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://backend-instance-2.benchmark-2/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://backend-instance-3.benchmark-2/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://nginx-setup-1.benchmark-2/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://nginx-setup-2.benchmark-2/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://nginx-setup-3.benchmark-2/what-is-my-name
do_curl_request -d 'name=Valeriy%20Zainullin' -X POST \
  http://nginx-setup-2-withcache.benchmark-2/what-is-my-name

echo -e "\e[32m""Ok!""\e[39m"
