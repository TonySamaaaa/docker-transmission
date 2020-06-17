FROM alpine

LABEL maintainer="Tony <i@tony.moe>"

ENV TRANSMISSION_VERSION 2.94

COPY mod.patch /usr/mod.patch

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
  && curl -sL https://github.com/transmission/transmission-releases/raw/master/transmission-${TRANSMISSION_VERSION}.tar.xz \
    | xz -d \
    | tar --strip-components 1 -C transmission -xf - \
  && cd transmission \
  && patch -p1 < /usr/mod.patch \
  && ./configure \
  && make \
  && make install \
  \
  && strip /usr/local/bin/transmission-* \
  && rm -rf /usr/src /usr/mod.patch \
  \
  && runDeps=$( \
    scanelf --needed --nobanner --format '%n#p' /usr/local/bin/transmission-* \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  ) \
  && apk add --no-cache --virtual .transmission-rundeps $runDeps \
  && apk del .build-deps

COPY config /config

EXPOSE 9091 51413

CMD ["transmission-daemon","-f","-g","/config"]