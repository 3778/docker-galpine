FROM ubuntu:19.10 AS glibc-builder

# TODO: latest glibc version is 2.31 @ 2020-02-01
ARG GLIBC_VERSION=2.30
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt update && apt install -y \
    bison build-essential gawk gettext openssl python3 texinfo

WORKDIR /glibc-build

# Write configparams file - TODO: I think this is not being used at all
RUN echo 'slibdir=/usr/glibc-compat/lib'     >  configparams && \
    echo 'rtlddir=/usr/glibc-compat/lib'     >> configparams && \
    echo 'sbindir=/usr/glibc-compat/bin'     >> configparams && \
    echo 'rootsbindir=/usr/glibc-compat/bin' >> configparams && \
    echo 'build-programs=yes'                >> configparams

# Download & extract glibc sources
ADD https://ftpmirror.gnu.org/libc/glibc-$GLIBC_VERSION.tar.gz glibc.tar.gz
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

COPY --from=glibc-builder /glibc-bin.tar.gz /glibc.tar.gz
# TODO: build APK as of https://github.com/sgerrand/alpine-pkg-glibc

