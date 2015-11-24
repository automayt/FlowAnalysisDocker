#####################################################################
# Dockerfile to build SiLK, YAF, and FlowBAT
# Based on Ubuntu
#
# The preferred method for using FlowBAT is via the Ubuntu installation
# instructions at http://www.flowbat.com/installation.html. This image
# is for testing only.
#
# Check out http://www.flowbat.com
# Check out https://github.com/chrissanders/FlowBAT
# Thanks to https://github.com/redjack/docker-silk
# Thanks to https://github.com/dockerfile/nodejs
#####################################################################

FROM ubuntu:trusty
MAINTAINER Jason Smith <jason.smith.webmail@gmail.com>

EXPOSE 1800
EXPOSE 18000
EXPOSE 18001

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
    gcc \
    git-core \
    mongodb-server \
    checkinstall \
    wget

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

# Download and install nodejs
# Install Node.js
RUN cd /tmp \
    && wget http://nodejs.org/dist/node-latest.tar.gz \
    && tar xvzf node-latest.tar.gz \
    && rm -f node-latest.tar.gz \
    && cd node-v* \
    && ./configure \
    && CXX="g++ -Wno-unused-local-typedefs" make \
    && CXX="g++ -Wno-unused-local-typedefs" make install \
    && cd /tmp \
    && rm -rf /tmp/node-v* \
    && npm install -g npm \
    && printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc
    WORKDIR /datanode
    CMD ["bash"]
