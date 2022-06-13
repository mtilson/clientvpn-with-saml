FROM ubuntu:22.04 as build-ovpn

ARG OVPN_VER=2.5.7
COPY openvpn-${OVPN_VER}-aws.patch /app/
WORKDIR /app

RUN apt-get update -y \
 && apt-get install patch make curl gcc liblzo2-dev liblz4-dev libssl-dev openssl -y \
 && curl -LO https://swupdate.openvpn.org/community/releases/openvpn-${OVPN_VER}.tar.gz \
 && tar -zxf openvpn-${OVPN_VER}.tar.gz \
 && cd openvpn-${OVPN_VER} \
 && cat /app/openvpn-${OVPN_VER}-aws.patch | patch -f -p 1 \
 && ./configure --enable-static --disable-shared --disable-debug --disable-plugins \
      OPENSSL_CFLAGS="-I/usr/include" OPENSSL_LIBS="-L/usr/lib -lssl -lcrypto" \
      LZO_CFLAGS="-I/usr/include" LZO_LIBS="-L/usr/lib -llzo2" \
      LZ4_CFLAGS="-I/usr/include" LZ4_LIBS="-L/usr/lib -llz4" \
 && make LIBS="-all-static" \
 && make install \
 && strip /usr/local/sbin/openvpn


FROM umputun/baseimage:buildgo-latest as build-saml
ARG EXPOSE_PORT=35001

ENV TIME_ZONE=Etc/UTC
RUN \
    echo "${TIME_ZONE}" > /etc/timezone && \
    cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

WORKDIR /build
ADD . /build

RUN go fmt ./...
RUN go test -mod=vendor ./...
RUN golangci-lint run --out-format=tab --tests=false ./...

RUN \
    revison=$(/script/git-rev.sh) && \
    echo "revision=${revison}" && \
    go build -mod=vendor -o app -ldflags "-X main.revision=$revison -X main.httpPort=$EXPOSE_PORT -s -w" .


FROM alpine:latest
ARG EXPOSE_PORT=35001

ARG OVPN_CONF=/srv/ovpn.conf
ENV OVPN_CONF=$OVPN_CONF

RUN \
    apk add --no-cache --update tzdata curl ca-certificates openssl bind-tools && \
    rm -rf /var/cache/apk/*

COPY --from=build-ovpn /usr/local/sbin/openvpn /usr/local/sbin/openvpn
RUN openvpn --version

COPY --from=build-saml /build/app /srv/saml-wrapper
EXPOSE $EXPOSE_PORT
WORKDIR /srv

COPY wrapper.sh ./
#COPY ovpn.conf ./

CMD ["/srv/saml-wrapper"]

# ./configure IFCONFIG=/sbin/ifconfig ROUTE=/sbin/route NETSTAT=/bin/netstat IPROUTE=/sbin/ip --enable-iproute2
