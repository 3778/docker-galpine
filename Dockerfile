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

FROM alpine:3.11
ARG VERSION=0.1.0
ARG APK_URL=https://github.com/3778/docker-galpine/releases/$VERSION
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8
ENV LANG=$LANG LC_ALL=$LC_ALL

# TODO can we parametrize UTF-8 with build ARG? can we run `localedef` in a previous build step?
RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget $APK_URL/glibc.apk $APK_URL/glibc-bin.apk $APK_URL/glibc-i18n.apk && \
    apk add --allow-untrusted --no-cache /glibc.apk /glibc-bin.apk /glibc-i18n.apk && \
    /usr/glibc/bin/localedef --force --inputfile POSIX --charmap UTF-8 $LC_ALL || true && \
    apk del glibc-i18n && apk del .build-dependencies && rm /*.apk

