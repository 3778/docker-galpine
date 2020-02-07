FROM ubuntu:19.10 AS glibc-builder

# TODO: latest glibc version is 2.31 @ 2020-02-01
ARG GLIBC_VERSION=2.30
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt update && apt install -y \
    bison build-essential gawk gettext openssl python3 texinfo

WORKDIR /glibc-build

# Write configparams file
RUN echo 'slibdir=/usr/glibc-compat/lib'     >  configparams && \
    echo 'rtlddir=/usr/glibc-compat/lib'     >> configparams && \
    echo 'sbindir=/usr/glibc-compat/bin'     >> configparams && \
    echo 'rootsbindir=/usr/glibc-compat/bin' >> configparams && \
    echo 'build-programs=yes'                >> configparams

# Download & extract glibc sources

ADD http://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.gz glibc.tar.gz
RUN tar zxf glibc.tar.gz && rm glibc.tar.gz

# Configure pre-build options with required output target and flags
RUN mkdir -p /usr/glibc-compat/lib
RUN glibc-$GLIBC_VERSION/configure \
    --prefix=/usr/glibc-compat \
    --libdir=/usr/glibc-compat/lib \
    --libexecdir=/usr/glibc-compat/lib \
    --enable-multi-arch \
    --enable-stack-protector=strong \
    --enable-cet

# Build glibc
RUN make

# Install glibc at /usr/glibc-compat
RUN make install

# Create final compressed archive
RUN tar --dereference --hard-dereference \
    -zcf /glibc-bin.tar.gz /usr/glibc-compat

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
FROM alpine:3.11 AS apk-builder

RUN apk add alpine-sdk

# Cannot use abuild tool as root user
RUN adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder
RUN echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /apk
RUN chown builder:abuild /apk
USER builder

# APK souce files
COPY APKBUILD APKBUILD
COPY --from=glibc-builder /glibc-bin.tar.gz glibc.tar.gz
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
COPY --from=apk-builder /home/builder/.abuild/*.pub /etc/apk/keys/

# Install APK
COPY --from=apk-builder /home/builder/packages/x86_64/glibc-2.30-r0.apk /opt/glibc-2.30-r0.apk
RUN apk add --no-cache /opt/glibc-2.30-r0.apk

# Generate locales
COPY --from=apk-builder /home/builder/packages/x86_64/glibc-bin-2.30-r0.apk /opt/glibc-bin-2.30-r0.apk
COPY --from=apk-builder /home/builder/packages/x86_64/glibc-i18n-2.30-r0.apk /opt/glibc-i18n-2.30-r0.apk
RUN apk add --no-cache /opt/glibc-bin-2.30-r0.apk
RUN apk add --no-cache /opt/glibc-i18n-2.30-r0.apk
RUN /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "C.UTF-8" || true
RUN echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh

# Clear unnecesary files
RUN apk del glibc-i18n
RUN rm /opt/*.apk
