ARG BASE_IMAGE=library/debian:stable-slim

FROM docker.io/library/golang:latest AS builder

ARG FMDSERVER_REPO=https://gitlab.com/Nulide/findmydeviceserver
ARG FMDSERVER_TAG=v0.8.0

ENV GOPATH /go

WORKDIR /go/src/findmydeviceserver
RUN <<-EOT sh
	set -eu

	apt-get update
	env DEBIAN_FRONTEND=noninteractive \
		apt-get install -y npm \
		-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
	apt-get clean && rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/*

	wget ${FMDSERVER_REPO}/-/archive/${FMDSERVER_TAG}/findmydeviceserver-${FMDSERVER_TAG}.tar.gz -O - \
		| tar -xzv --strip-components=1
	go build -o /tmp/fmd main.go
EOT

FROM docker.io/${BASE_IMAGE}

RUN <<-EOT sh
	set -eu

	apt-get update
	env DEBIAN_FRONTEND=noninteractive \
		apt-get install -y ca-certificates \
		-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
	apt-get clean && rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/*
EOT

COPY --from=builder /tmp/fmd /fmd/server
COPY --from=builder /go/src/findmydeviceserver/web /fmd/web

RUN useradd --create-home --uid 1000 fmd-user
RUN chown -R fmd-user:fmd-user /fmd

USER fmd-user
WORKDIR /fmd

EXPOSE 8080/tcp
EXPOSE 8443/tcp

HEALTHCHECK --interval=1m --timeout=3s \
  CMD timeout 2 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/8080'

ENTRYPOINT ["/fmd/server", "serve"]
