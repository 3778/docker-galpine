# ISC License
#
# Copyright 2020; 3778 Care <platform@3778.care>
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose with or without fee is hereby granted, provided
# that the above copyright notice and this permission notice
# appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
# NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

FROM ubuntu:19.10 AS builder-glibc
WORKDIR /usr/src/glibc

ARG GLIBC_SIGKEY=BC7C7372637EC10C57D7AA6579C43DFBF1CF2187
ARG GLIBC_VERSION=2.31
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8

RUN apt update && apt install -y --no-install-recommends --no-upgrade \
    gpg gpg-agent dirmngr build-essential bison gawk python3

ADD https://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.xz     glibc.tar.xz
ADD https://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.xz.sig glibc.sig
RUN gpg --keyserver hkps://hkps.pool.sks-keyservers.net --receive-keys $GLIBC_SIGKEY
RUN gpg --verify glibc.sig glibc.tar.xz
RUN tar --extract --xz --strip-components=1 --file=glibc.tar.xz && rm glibc.tar.xz

# BUILD FINAL ARTIFACT @ /glibc-bin.tar.xz
WORKDIR /root
RUN mkdir -p /usr/glibc/lib
RUN /usr/src/glibc/configure \
    --prefix=/usr/glibc \
    --libdir=/usr/glibc/lib \
    --libexecdir=/usr/glibc/lib \
    --enable-multi-arch \
    --enable-stack-protector=strong \
    --enable-cet
RUN make PARALLELMFLAGS="-j $(nproc)" && make install
RUN tar --create --xz --dereference --hard-dereference --file=/glibc-bin.tar.xz /usr/glibc/*


FROM alpine:3.11 AS builder-apk
RUN apk add alpine-sdk
RUN adduser -D builder -G abuild
RUN echo 'builder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN mkdir /packages && chown builder:abuild /packages /opt

USER builder
RUN mkdir -p /home/builder/glibc/src
WORKDIR /home/builder/glibc/src

# CONFIGURE APK BUILD ENVIRONMENT
COPY APKBUILD .
COPY --from=builder-glibc /glibc-bin.tar.xz .
RUN echo /usr/local/lib >  ld.so.conf && \
    echo /usr/glibc/lib >> ld.so.conf && \
    echo /usr/lib       >> ld.so.conf && \
    echo /lib           >> ld.so.conf
RUN echo '#!/bin/sh'               >  glibc-bin.trigger && \
    echo  /usr/glibc/sbin/ldconfig >> glibc-bin.trigger && \
    chmod 775 glibc-bin.trigger
RUN abuild checksum

# BUILD PACKAGE (NOTE signed with build-time ephemeral key)
ARG GLIBC_VERSION=2.31
RUN abuild-keygen -ain && abuild -r -P /packages

# TODO check if we need all `*.apk` files or just `glibc-bin-*.apk` or naked `glibc.apk`
# TODO apk uses `home/x86_64` as repository index, we should remove the `home` part
RUN cp /packages/glibc/x86_64/glibc-$GLIBC_VERSION-r0.apk /opt/glibc.apk
RUN cp /packages/glibc/x86_64/glibc-bin-*.apk             /opt/glibc-bin.apk
RUN cp /packages/glibc/x86_64/glibc-i18n-*.apk            /opt/glibc-i18n.apk
