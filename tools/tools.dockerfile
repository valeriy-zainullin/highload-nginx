FROM ubuntu:23.10

# Install packages and delete package lists,
#   so that it's not possible to install packages anymore.
#   I little bit more security for the case, when the
#   container is compromised.

# https://stackoverflow.com/a/35976127
ARG DEBIAN_FRONTEND=noninteractive

# May be reused for other containers.
RUN apt-get update && apt-get install apt-utils

RUN apt-get install -y csvkit apache2-utils curl && rm -rf /var/lib/apt/lists/*

# Не пересобирать контейнер, если поменялся лишь скрипт.
#   Закинем его последним.
COPY tools.bash /tools.bash
RUN chmod +x /tools.bash

COPY prepare_post_file.bash /prepare_post_file.bash
RUN chmod +x /prepare_post_file.bash

ENTRYPOINT ["/tools.bash"]
