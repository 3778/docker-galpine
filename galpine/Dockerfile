FROM ubuntu:latest AS builder-glibc
ENV  LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt update && apt install -y bison build-essential gawk gettext openssl \
    python3 texinfo

ARG GLIBC_VERSION=2.30
RUN mkdir -p /glibc-build

# WRITE CONFIGPARAMS FILE
RUN echo 'slibdir=/usr/glibc-compat/lib'     >  /glibc-build/configparams && \
    echo 'rtlddir=/usr/glibc-compat/lib'     >> /glibc-build/configparams && \
    echo 'sbindir=/usr/glibc-compat/bin'     >> /glibc-build/configparams && \
    echo 'rootsbindir=/usr/glibc-compat/bin' >> /glibc-build/configparams && \
    echo 'build-programs=yes'                >> /glibc-build/configparams

# GET GLIBC TARBALL
ADD https://ftpmirror.gnu.org/libc/glibc-$GLIBC_VERSION.tar.gz glibc.tar.gz
RUN cat glibc.tar.gz | tar zxf -  # NOTE decompressed to /glibc-$GLIBC_VERSION/*

WORKDIR /glibc-build

RUN mkdir -p /glibc-compat/etc && touch /glibc-compat/etc/ld.so.conf
RUN /glibc-$GLIBC_VERSION/configure --prefix=/usr/glibc-compat \
                                    --libdir=/usr/glibc-compat/lib \
                                    --libexecdir=/usr/glibc-compat/lib \
                                    --enable-multi-arch \
                                    --enable-stack-protector=strong
RUN make && make install
RUN tar --dereference --hard-dereference -zcf /glibc-bin.tar.gz /usr/glibc-compat


FROM alpine:3 AS builder-apk
COPY --from=builder-glibc /glibc-bin.tar.gz .

#FROM alpine:3
#ENV LANG=C.UTF-8 LC_ALL=C.UTF-8


#RUN GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    #GLIBC_PACKAGE_VERSION="2.30-r0" && \
    #GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    #GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    #GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    #apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    #echo \
        #"-----BEGIN PUBLIC KEY-----\
        #MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        #y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        #tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        #m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        #KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        #Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        #1QIDAQAB\
        #-----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    #wget \
        #"$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        #"$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        #"$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    #apk add --no-cache \
        #"$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        #"$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        #"$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    #\
    #rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    #/usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    #echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    #\
    #apk del glibc-i18n && \
    #\
    #rm "/root/.wget-hsts" && \
    #apk del .build-dependencies && \
    #rm \
        #"$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        #"$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        #"$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"
