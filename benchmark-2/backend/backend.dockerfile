FROM ubuntu:23.10

# Install packages and delete package lists,
#   so that it's not possible to install packages anymore.
#   I little bit more security for the case, when the
#   container is compromised.
RUN apt-get update && apt-get install -y golang tini && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["tini", "--"]

# Running from root is not fine in this case.
#   Because root in a container = root on the host.
#   Don't repeat this in production!
COPY backend.go /backend.go
CMD  ["go", "run", "/backend.go"]
