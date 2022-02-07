FROM alpine AS build-deps

LABEL maintainer="Tony <i@tony.moe>"

ENV VERSION 3.00

COPY mod.patch /root/mod.patch

RUN apk add --no-cache --virtual .build-deps \
    automake \
    bsd-compat-headers \
    curl \
    curl-dev \
    g++ \
    gcc \
    gettext \
    gtk+3.0-dev \
    intltool \
    libevent-dev \
    libtool \
    linux-headers \
    m4 \
    make \
    openssl-dev \
    patch \
    xz \
  \
  && mkdir /usr/src \
  && cd /usr/src \
  \
  && mkdir transmission \
  && curl -sL https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-${VERSION}.tar.xz \
    | xz -d \
    | tar --strip-components 1 -C transmission -xf - \
  && cd transmission \
  && patch -p1 < /root/mod.patch \
  && ./configure \
  && make \
  && make install DESTDIR=/usr/src/build-deps \
  \
  && cd .. \
  && strip build-deps/usr/local/bin/transmission-*

FROM alpine

COPY --from=build-deps /usr/src/build-deps /

RUN runDeps=$( \
    scanelf --needed --nobanner --format '%n#p' /usr/local/bin/transmission-* \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  ) \
  && apk add --no-cache --virtual .transmission-rundeps $runDeps

COPY config /config

VOLUME ["/config", "/downloads", "/watch"]
EXPOSE 9091 51413 51413/udp

CMD ["transmission-daemon", "-f", "-g", "/config"]
