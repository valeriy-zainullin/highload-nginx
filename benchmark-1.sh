#!/bin/bash

set -e

CSV_LINES=''
store_line() {
    CSV_LINES="$CSV_LINES""$1"$'\n'
}

store_line "Setup:Path:Proxy caching:Balancing:Requests in batch:Requests per second"

logs_file=$(mktemp)

post_data='name=Alexander%20Sergeevich%20Pushkin'

# Ab requires trailing slash after URL.
#   https://stackoverflow.com/a/10975469

run_bench() {
    # Output name
    echo -n "$1"

    echo -n " $2"

    if [ ! -z "$3" ]; then
        echo -n " proxy-caching:$3"
    fi

    if [ ! -z "$4" ]; then
        echo -n " balancing:$4"
    fi

    echo -n " $5"'-reqs-in-batch: '

    post_options=''
    if [ ! -z "$7" ]; then
      # https://gist.github.com/kelvinn/6a1c51b8976acf25bd78
      # -p means to POST it
      # -T sets the Content-Type
      # https://stackoverflow.com/a/29870966
      post_options="-p /post.txt -T application/x-www-form-urlencoded"
    fi

    # Output results
    # "-T" so that it doesn't allocate a tty.
    #   Otherwise it gets stuck in a funny mode,
    #   where "\n" only changes line, but doesn't
    #   bring carriage to the start of the next line.
    #   Not the behaviour linux terminals have by default.
    # The link below is about a situation a man ended up,
    #   but it made an idea I could have a similar funny
    #   mode going on.https://unix.stackexchange.com/a/492811
    # docker-compose run -T --rm tools ab -n8000 -c"$2" "$3" 2>&1 | grep -Po "Requests per second: *\K[0-9.]+ " | tr -d ' '

    result=$((docker-compose run -T --rm tools /prepare_post_file.bash "$7" /post.txt ab $post_options -n8000 -c"$5" "http://$6.benchmark-1$2" 2> $logs_file) || (echo 1>&2; cat $logs_file 1>&2; exit 1))

    if echo "$result" | grep "Failed requests: *[1-9][0-9]* *" > /dev/null; then
        echo -e "\nThere are failed requests!" 1>&2
        echo "$result"
        exit 1
    fi

    if echo "$result" | grep "Non-2xx responses: *[1-9][0-9]* *" > /dev/null; then
        echo -e "\nThere are non-2xx responses!" 1>&2
        echo "$result"
        exit 1
    fi

    num_reqs_per_sec=$(echo "$result" | grep -Po "Requests per second: *\K[0-9.]+ " | tr -d ' ')
    store_line "$1:$2:$3:$4:$5:$num_reqs_per_sec"

    echo "$num_reqs_per_sec"
}


run_bench "backend (single instance)" "/what-date-is-it" "" "" 1 backend-instance-1
run_bench "backend (single instance)" "/what-date-is-it" "" "" 6 backend-instance-1
run_bench "backend (single instance)" "/what-is-my-name" "" "" 1 backend-instance-1 "$post_data"
run_bench "backend (single instance)" "/what-is-my-name" "" "" 6 backend-instance-1 "$post_data"

run_bench "nginx-setup-1" "/what-date-is-it" "no" "no" 1 nginx-setup-1
run_bench "nginx-setup-1" "/what-date-is-it" "no" "no" 6 nginx-setup-1
run_bench "nginx-setup-1" "/what-is-my-name" "no" "no" 1 nginx-setup-1 "$post_data"
run_bench "nginx-setup-1" "/what-is-my-name" "no" "no" 6 nginx-setup-1 "$post_data"

run_bench "nginx-setup-2" "/what-date-is-it" "no" "yes" 1 nginx-setup-2
run_bench "nginx-setup-2" "/what-date-is-it" "no" "yes" 6 nginx-setup-2
run_bench "nginx-setup-2" "/what-is-my-name" "no" "yes" 1 nginx-setup-2 "$post_data"
run_bench "nginx-setup-2" "/what-is-my-name" "no" "yes" 6 nginx-setup-2 "$post_data"

run_bench "nginx-setup-2-withcache" "/what-date-is-it" "yes" "yes" 1 nginx-setup-2-withcache
run_bench "nginx-setup-2-withcache" "/what-date-is-it" "yes" "yes" 6 nginx-setup-2-withcache
run_bench "nginx-setup-2-withcache" "/what-is-my-name" "no" "yes" 1 nginx-setup-2-withcache "$post_data"
run_bench "nginx-setup-2-withcache" "/what-is-my-name" "no" "yes" 6 nginx-setup-2-withcache "$post_data"

run_bench "nginx-setup-3" "/what-date-is-it" "no" "uneven" 1 nginx-setup-3
run_bench "nginx-setup-3" "/what-date-is-it" "no" "uneven" 6 nginx-setup-3
run_bench "nginx-setup-3" "/what-is-my-name" "no" "yes" 1 nginx-setup-3 "$post_data"
run_bench "nginx-setup-3" "/what-is-my-name" "no" "yes" 6 nginx-setup-3 "$post_data"

# Output ready-to-go markdown.
#   https://unix.stackexchange.com/a/677347
[ -d results ] || mkdir results
echo "$CSV_LINES" | docker-compose run -T --rm tools csvlook 2>/dev/null > results/benchmark-1.txt
