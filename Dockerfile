ARG BASE_IMAGE=library/debian:bullseye-slim

FROM docker.io/library/golang:bullseye AS builder

ARG FMDSERVER_REPO=https://gitlab.com/Nulide/findmydeviceserver
ARG FMDSERVER_TAG=v0.3.6

ENV GOPATH /go

WORKDIR /go/src/findmydeviceserver
RUN \
  wget ${FMDSERVER_REPO}/-/archive/${FMDSERVER_TAG}/findmydeviceserver-${FMDSERVER_TAG}.tar.gz -O - \
  | tar -xzv --strip-components=1

ADD https://raw.githubusercontent.com/objectbox/objectbox-go/main/install.sh objectbox-install.sh
RUN chmod u+x objectbox-install.sh \
  && ./objectbox-install.sh

RUN go build -o /fmd cmd/fmdserver.go

FROM docker.io/${BASE_IMAGE}

COPY --from=builder /fmd /fmd/server
COPY --from=builder /go/src/findmydeviceserver/web /fmd/web
COPY --from=builder /go/src/findmydeviceserver/extra /fmd/extra
COPY --from=builder /usr/lib/libobjectbox.so /usr/lib/libobjectbox.so

RUN useradd -m -u 1000 user
RUN mkdir /fmd/objectbox \
  && chown user:user /fmd/objectbox
USER user

EXPOSE 1020/tcp
VOLUME /data

ENTRYPOINT ["/fmd/server"]
