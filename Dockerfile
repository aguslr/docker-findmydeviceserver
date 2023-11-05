ARG BASE_IMAGE=library/debian:bullseye-slim

FROM docker.io/library/golang:bullseye AS builder

ARG FMDSERVER_REPO=https://gitlab.com/Nulide/findmydeviceserver
ARG FMDSERVER_TAG=v0.4.0

ENV GOPATH /go

RUN \
  apt-get update && \
  env DEBIAN_FRONTEND=noninteractive \
  apt-get install -y npm \
  -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/*

WORKDIR /go/src/findmydeviceserver
RUN \
  wget ${FMDSERVER_REPO}/-/archive/${FMDSERVER_TAG}/findmydeviceserver-${FMDSERVER_TAG}.tar.gz -O - \
  | tar -xzv --strip-components=1

ADD https://raw.githubusercontent.com/objectbox/objectbox-go/main/install.sh objectbox-install.sh
RUN chmod u+x objectbox-install.sh \
  && ./objectbox-install.sh

RUN go build -o /fmd cmd/fmdserver.go
RUN npm install

FROM docker.io/${BASE_IMAGE}

RUN \
  apt-get update && \
  env DEBIAN_FRONTEND=noninteractive \
  apt-get install -y ca-certificates \
  -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/*

COPY --from=builder /fmd /fmd/server
COPY --from=builder /go/src/findmydeviceserver/node_modules /fmd/web/node_modules
COPY --from=builder /usr/lib/libobjectbox.so /usr/lib/libobjectbox.so
COPY --from=builder /go/src/findmydeviceserver/web /fmd/web
COPY --from=builder /go/src/findmydeviceserver/extra /fmd/extra

RUN useradd -m -u 1000 user
RUN mkdir /fmd/objectbox \
  && chown user:user /fmd/objectbox
USER user

EXPOSE 1020/tcp
VOLUME /data

HEALTHCHECK --interval=1m --timeout=3s \
  CMD timeout 2 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/1020'

ENTRYPOINT ["/fmd/server"]
