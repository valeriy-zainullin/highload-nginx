FROM ubuntu:23.10

# Install packages and delete package lists,
#   so that it's not possible to install packages anymore.
#   I little bit more security for the case, when the
#   container is compromised.

# https://stackoverflow.com/a/35976127
ARG DEBIAN_FRONTEND=noninteractive

# May be reused for other containers.
RUN apt-get update && apt-get -yq install apt-utils

# Setting timezones in docker containers.
#   https://dev.to/0xbf/set-timezone-in-your-docker-image-d22
RUN apt-get update && \
    apt-get install -yq tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN apt-get install -yq csvkit apache2-utils curl && rm -rf /var/lib/apt/lists/*

# Не пересобирать контейнер, если поменялся лишь скрипт.
#   Закинем его последним.
COPY tools.bash prepare_post_file.bash do_curl_request.bash /
RUN chmod +x /*.bash

ENTRYPOINT ["/tools.bash"]
