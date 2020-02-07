FROM ubuntu:19.10 AS builder-glibc
WORKDIR /usr/src/glibc

ARG GLIBC_SIGKEY=CCECECECE
# TODO latest glibc version is 2.31 @ 2020-02-01
ARG GLIBC_VERSION=2.30
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8

# TODO trim this up? AND ADD gpg TO THE LIST (if its not in by default already)
RUN apt update && apt install -y --no-install-recommends --no-upgrade \
    bison build-essential gawk gettext openssl python3 texinfo

# TODO are the parameters in `glibc-*/configure` enough? is this block needed?
RUN echo slibdir=/usr/glibc/lib     >  configparams && \
    echo rtlddir=/usr/glibc/lib     >> configparams && \
    echo sbindir=/usr/glibc/bin     >> configparams && \
    echo rootsbindir=/usr/glibc/bin >> configparams && \
    echo build-programs=yes         >> configparams

ADD https://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.xz     glibc.tar.xz
ADD https://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.xz.sig glibc.sig
# TODO does this gpg thing work?
#RUN gpg --recv-key=$GLIBC_SIGKEY && gpg glibc.sig && gpg --verify=glibc.sig glibc.tar.xz
RUN tar --extract --xz --strip-components=1 --file=glibc.tar.xz && rm glibc.tar.xz

# BUILD FINAL ARTIFACT @ /glibc-bin.tar.xz
WORKDIR /root/
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
USER builder
WORKDIR /home/builder

# CONFIGURE APK BUILD ENVIRONMENT
COPY APKBUILD .
COPY --from=builder-glibc /glibc-bin.tar.xz .
# TODO what is this for? do we need this?
RUN echo hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4 > nsswitch.conf
# TODO check what we are changing from default ld.so.conf and if we really need this
RUN echo /usr/local/lib >  ld.so.conf && \
    echo /usr/glibc/lib >> ld.so.conf && \
    echo /usr/lib       >> ld.so.conf && \
    echo /lib           >> ld.so.conf
# TODO what is this for? do we need this?
RUN echo '#!/bin/sh'               >  glibc-bin.trigger && \
    echo  /usr/glibc/sbin/ldconfig >> glibc-bin.trigger && \
    chmod 775 glibc-bin.trigger
RUN abuild checksum

# BUILD PACKAGE (NOTE signed with build-time ephemeral key)
RUN abuild-keygen -ain && abuild -r


FROM alpine:3.11
# TODO check if we need all `*.apk` files or just `glibc-bin-*.apk` or naked `glibc.apk`
COPY --from=builder-apk /home/builder/packages/home/x86_64/glibc-2.30-r0.apk /opt/glibc.apk
COPY --from=builder-apk /home/builder/packages/home/x86_64/glibc-bin-*.apk   /opt/glibc-bin.apk
COPY --from=builder-apk /home/builder/packages/home/x86_64/glibc-i18n-*.apk  /opt/glibc-i18n.apk
RUN apk add --allow-untrusted --no-cache /opt/glibc.apk /opt/glibc-bin.apk /opt/glibc-i18n.apk

# GENERATE LOCALES
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8
ENV LANG=$LANG LC_ALL=$LC_ALL
# TODO can we parametrize UTF-8 with build ARG? can we run `localedef` in a previous build step?
RUN /usr/glibc/bin/localedef --force --inputfile POSIX --charmap UTF-8 $LC_ALL || true

# GARBAGE COLLECTOR
RUN apk del glibc-i18n && rm /opt/*.apk

