FROM ubuntu:19.10 AS builder-glibc
WORKDIR /glibc-build

ARG GLIBC_SIGKEY=CCECECECE
# TODO latest glibc version is 2.31 @ 2020-02-01
ARG GLIBC_VERSION=2.30
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8

# TODO trim this up? AND ADD gpg TO THE LIST (if its not in by default already)
RUN apt update && apt install -y --no-install-recommends --no-upgrade \
    bison build-essential gawk gettext openssl python3 texinfo

# TODO are the parameters in `glibc-*/configure` enough? is this block needed?
RUN echo 'slibdir=/usr/glibc-compat/lib'     >  configparams && \
    echo 'rtlddir=/usr/glibc-compat/lib'     >> configparams && \
    echo 'sbindir=/usr/glibc-compat/bin'     >> configparams && \
    echo 'rootsbindir=/usr/glibc-compat/bin' >> configparams && \
    echo 'build-programs=yes'                >> configparams

ADD https://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.xz     glibc.tar.xz
ADD https://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.xz.sig glibc.sig
# TODO does this gpg thing work?
#RUN gpg --recv-key=$GLIBC_SIGKEY && gpg glibc.sig && gpg --verify=glibc.sig glibc.tar.xz
RUN tar --extract --xz --strip-components=1 --file=glibc.tar.xz && rm glibc.tar.xz

# BUILD FINAL ARTIFACT @ /glibc-bin.tar.xz
RUN mkdir -p /usr/glibc-compat/lib
RUN ./configure \
    --prefix=/usr/glibc-compat \
    --libdir=/usr/glibc-compat/lib \
    --libexecdir=/usr/glibc-compat/lib \
    --enable-multi-arch \
    --enable-stack-protector=strong \
    --enable-cet
RUN make && make install
RUN tar --create --xz --dereference --hard-dereference --file=/glibc-bin.tar.xz /usr/glibc-compat/*


FROM alpine:3.11 AS builder-apk

RUN apk add alpine-sdk

# Cannot use abuild tool as root user
RUN adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder
RUN echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /apk
RUN chown builder:abuild /apk
USER builder

# APK souce files
COPY APKBUILD APKBUILD
COPY --from=builder-glibc /glibc-bin.tar.xz
RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' > nsswitch.conf
# libc default configuration
RUN echo '/usr/local/lib'        >  ld.so.conf && \
    echo '/usr/glibc-compat/lib' >> ld.so.conf && \
    echo '/usr/lib'              >> ld.so.conf && \
    echo '/lib'                  >> ld.so.conf
RUN echo '#!/bin/sh' > glibc-bin.trigger && \
    echo '/usr/glibc-compat/sbin/ldconfig' >> glibc-bin.trigger && \
    chmod 775 glibc-bin.trigger
RUN abuild checksum

# Generate apk keys & build package at $HOME/packages/x86_64
RUN abuild-keygen -ain
RUN abuild -r

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
FROM alpine:3.11

# Retrieve public key from abuild-keygen
COPY --from=builder-apk /home/builder/.abuild/*.pub /etc/apk/keys/

# Install APK
COPY --from=builder-apk /home/builder/packages/x86_64/glibc-2.30-r0.apk /opt/glibc-2.30-r0.apk
RUN apk add --no-cache /opt/glibc-2.30-r0.apk

# Generate locales
COPY --from=builder-apk /home/builder/packages/x86_64/glibc-bin-2.30-r0.apk /opt/glibc-bin-2.30-r0.apk
COPY --from=builder-apk /home/builder/packages/x86_64/glibc-i18n-2.30-r0.apk /opt/glibc-i18n-2.30-r0.apk
RUN apk add --no-cache /opt/glibc-bin-2.30-r0.apk
RUN apk add --no-cache /opt/glibc-i18n-2.30-r0.apk
RUN /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "C.UTF-8" || true
RUN echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh

# Clear unnecesary files
RUN apk del glibc-i18n
RUN rm /opt/*.apk
