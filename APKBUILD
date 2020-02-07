pkgname="glibc"
pkgver="2.30"  # TODO parametrize with Dockerfile arg
pkgrel="0"
pkgdesc="GNU C Library compatibility layer for Alpine Linux"
url="https://github.com/3778/docker-galpine"
arch="x86_64"
license="LGPL"
subpackages="$pkgname-dev $pkgname-bin $pkgname-i18n"
source="glibc-bin.tar.xz nsswitch.conf ld.so.conf"
triggers="$pkgname-bin.trigger=/lib:/usr/lib:/usr/glibc/lib"

# TODO these escaping quotes are not necessary unless abuild wants them
package() {  # TODO can this be named `dev` to match the other build recipes
    mkdir -p "$pkgdir/lib" "$pkgdir/lib64" "$pkgdir/usr/glibc/lib/locale" "$pkgdir"/usr/glibc/lib64 "$pkgdir"/etc
    cp -a "$srcdir"/usr "$pkgdir"
    cp "$srcdir"/ld.so.conf "$pkgdir"/usr/glibc/etc/ld.so.conf
    cp "$srcdir"/nsswitch.conf "$pkgdir"/etc/nsswitch.conf
    rm "$pkgdir"/usr/glibc/etc/rpc
    rm -rf "$pkgdir"/usr/glibc/bin
    rm -rf "$pkgdir"/usr/glibc/sbin
    rm -rf "$pkgdir"/usr/glibc/lib/gconv
    rm -rf "$pkgdir"/usr/glibc/lib/getconf
    rm -rf "$pkgdir"/usr/glibc/lib/audit
    rm -rf "$pkgdir"/usr/glibc/share
    rm -rf "$pkgdir"/usr/glibc/var
    ln -s /usr/glibc/lib/ld-linux-x86-64.so.2 ${pkgdir}/lib/ld-linux-x86-64.so.2
    ln -s /usr/glibc/lib/ld-linux-x86-64.so.2 ${pkgdir}/lib64/ld-linux-x86-64.so.2
    ln -s /usr/glibc/lib/ld-linux-x86-64.so.2 ${pkgdir}/usr/glibc/lib64/ld-linux-x86-64.so.2
    ln -s /usr/glibc/etc/ld.so.cache ${pkgdir}/etc/ld.so.cache
}

bin() {
    depends="$pkgname libgcc"
    mkdir -p "$subpkgdir"/usr/glibc
    cp -a "$srcdir"/usr/glibc/bin "$subpkgdir"/usr/glibc
    cp -a "$srcdir"/usr/glibc/sbin "$subpkgdir"/usr/glibc
}

i18n() {
    depends="$pkgname-bin"
    arch="noarch"
    mkdir -p "$subpkgdir"/usr/glibc
    cp -a "$srcdir"/usr/glibc/share "$subpkgdir"/usr/glibc
}

