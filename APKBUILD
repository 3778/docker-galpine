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

pkgname="glibc"
pkgver="$GLIBC_VERSION"
pkgrel="0"
pkgdesc="GNU C Library compatibility layer for Alpine Linux"
url="https://github.com/3778/docker-galpine"
arch="x86_64"
license="LGPL"
subpackages="$pkgname-dev $pkgname-bin $pkgname-i18n"
source="glibc-bin.tar.xz nsswitch.conf ld.so.conf"
triggers="$pkgname-bin.trigger=/lib:/usr/lib:/usr/glibc/lib"

package() {
    mkdir -p $pkgdir/lib $pkgdir/lib64 $pkgdir/usr/glibc/lib/locale $pkgdir/usr/glibc/lib64 $pkgdir/etc
    cp -a $srcdir/usr $pkgdir
    cp $srcdir/ld.so.conf $pkgdir/usr/glibc/etc/ld.so.conf
    cp $srcdir/nsswitch.conf $pkgdir/etc/nsswitch.conf
    rm $pkgdir/usr/glibc/etc/rpc
    rm -rf $pkgdir/usr/glibc/bin
    rm -rf $pkgdir/usr/glibc/sbin
    rm -rf $pkgdir/usr/glibc/lib/gconv
    rm -rf $pkgdir/usr/glibc/lib/getconf
    rm -rf $pkgdir/usr/glibc/lib/audit
    rm -rf $pkgdir/usr/glibc/share
    rm -rf $pkgdir/usr/glibc/var
    # FIXME these symbolic links error on trigger in galpine container
    ln -s /usr/glibc/lib/ld-linux-x86-64.so.2 $pkgdir/lib/ld-linux-x86-64.so.2
    ln -s /usr/glibc/lib/ld-linux-x86-64.so.2 $pkgdir/lib64/ld-linux-x86-64.so.2
    ln -s /usr/glibc/lib/ld-linux-x86-64.so.2 $pkgdir/usr/glibc/lib64/ld-linux-x86-64.so.2
    ln -s /usr/glibc/etc/ld.so.cache $pkgdir/etc/ld.so.cache
}

bin() {
    depends="$pkgname libgcc"
    mkdir -p $subpkgdir/usr/glibc
    cp -a $srcdir/usr/glibc/bin  $subpkgdir/usr/glibc
    cp -a $srcdir/usr/glibc/sbin $subpkgdir/usr/glibc
}

i18n() {
    depends="$pkgname-bin"
    arch="noarch"
    mkdir -p $subpkgdir/usr/glibc
    cp -a $srcdir/usr/glibc/share $subpkgdir/usr/glibc
}

