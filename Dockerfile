#####################################################################
# Dockerfile to build SiLK, YAF, and FlowBAT
# Based on Ubuntu
# Thanks to https://github.com/redjack/docker-silk for some guidance.
#####################################################################

FROM ubuntu:trusty
MAINTAINER Jason Smith <jason.smith.webmail@gmail.com>

ENV LIBFIXBUF_VERSION 1.7.1
ENV SILK_VERSION 3.11.0.1
ENV YAF_VERSION 2.7.1

# Install libfixbuf and SiLK dependencies
RUN apt-get update \
    && apt-get -y install \
    man \
    build-essential \
    pkg-config \
    libglib2.0-dev \
    libssl-dev \
    libpcre3-dev \
    zlib1g \
    bison \
    flex \
    libc-ares-dev \
    libgnutls-dev \
    libpcap0.8-dev \
    liblzo2-dev \
    libdbi-perl \
    curl \
    glib2.0 \
    libglib2.0-dev \
    g++ \
    python-dev \
    make \
    gcc

# Download and build libfixbuf
RUN mkdir -p /src \
    && cd /src \
    && curl -f -L -O https://tools.netsa.cert.org/releases/libfixbuf-$LIBFIXBUF_VERSION.tar.gz \
    && tar zxf libfixbuf-$LIBFIXBUF_VERSION.tar.gz \
    && cd /src/libfixbuf-$LIBFIXBUF_VERSION \
    && ./configure --with-openssl \
    && make \
    && make install \
    && rm -rf /src

# Download and build SiLK
RUN mkdir -p /src \
    && cd /src \
    && curl -f -L -O https://tools.netsa.cert.org/releases/silk-$SILK_VERSION.tar.gz \
    && tar zxf silk-$SILK_VERSION.tar.gz \
    && cd /src/silk-$SILK_VERSION \
    && ./configure --enable-ipv6 --with-libfixbuf=/usr/local/lib/pkgconfig/ --with-python\
    && make \
    && make install \
    && rm -rf /src

# Download and build YAF
RUN mkdir -p /src \
    && cd /src \
    && curl -f -L -O http://tools.netsa.cert.org/releases/yaf-$YAF_VERSION.tar.gz \
    && tar zxf yaf-$YAF_VERSION.tar.gz \
    && export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
    && cd /src/yaf-$YAF_VERSION \
    && ./configure --enable-applabel \
    && make \
    && make install \
    && rm -rf /src

RUN ldconfig
