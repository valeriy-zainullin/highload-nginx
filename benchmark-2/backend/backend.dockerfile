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

RUN apt-get install -yq gunicorn python3 python3-flask tini && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["tini", "--"]

# Running from root is not fine in this case.
#   Because root in a container = root on the host.
#   Don't repeat this in production!
COPY backend.py /backend.py
CMD  ["gunicorn", "-w", "2", "--bind", "0.0.0.0:80", "backend:app"]
