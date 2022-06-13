FROM ubuntu:22.04 as build

ENV OVPN_VER=2.5.7
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

FROM alpine:latest

COPY --from=build /usr/local/sbin/openvpn /app/

WORKDIR /app
#RUN openvpn --version
#&& apt-get install patch make curl gcc liblzo2-dev libpam0g-dev libssl-dev openssl -y \
#IFCONFIG=/sbin/ifconfig ROUTE=/sbin/route NETSTAT=/bin/netstat IPROUTE=/sbin/ip --enable-iproute2
