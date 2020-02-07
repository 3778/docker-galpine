pkgname="glibc"
pkgver="2.30"  # TODO parametrize with Dockerfile arg
pkgrel="0"
pkgdesc="GNU C Library compatibility layer for Alpine Linux"
url="https://github.com/3778/docker-galpine"
arch="x86_64"
license="LGPL"
subpackages="$pkgname-dev $pkgname-bin $pkgname-i18n"
source="glibc-bin.tar.xz nsswitch.conf ld.so.conf"
triggers="$pkgname-bin.trigger=/lib:/usr/lib:/usr/glibc-compat/lib"

# TODO these escaping quotes are not necessary unless abuild wants them
package() {  # TODO can this be named `dev` to match the other build recipes
    mkdir -p "$pkgdir/lib" "$pkgdir/lib64" "$pkgdir/usr/glibc-compat/lib/locale" "$pkgdir"/usr/glibc-compat/lib64 "$pkgdir"/etc
    cp -a "$srcdir"/usr "$pkgdir"
    cp "$srcdir"/ld.so.conf "$pkgdir"/usr/glibc-compat/etc/ld.so.conf
    cp "$srcdir"/nsswitch.conf "$pkgdir"/etc/nsswitch.conf
    rm "$pkgdir"/usr/glibc-compat/etc/rpc
    rm -rf "$pkgdir"/usr/glibc-compat/bin
    rm -rf "$pkgdir"/usr/glibc-compat/sbin
    rm -rf "$pkgdir"/usr/glibc-compat/lib/gconv
    rm -rf "$pkgdir"/usr/glibc-compat/lib/getconf
    rm -rf "$pkgdir"/usr/glibc-compat/lib/audit
    rm -rf "$pkgdir"/usr/glibc-compat/share
    rm -rf "$pkgdir"/usr/glibc-compat/var
    ln -s /usr/glibc-compat/lib/ld-linux-x86-64.so.2 ${pkgdir}/lib/ld-linux-x86-64.so.2
    ln -s /usr/glibc-compat/lib/ld-linux-x86-64.so.2 ${pkgdir}/lib64/ld-linux-x86-64.so.2
    ln -s /usr/glibc-compat/lib/ld-linux-x86-64.so.2 ${pkgdir}/usr/glibc-compat/lib64/ld-linux-x86-64.so.2
    ln -s /usr/glibc-compat/etc/ld.so.cache ${pkgdir}/etc/ld.so.cache
}

bin() {
    depends="$pkgname libgcc"
    mkdir -p "$subpkgdir"/usr/glibc-compat
    cp -a "$srcdir"/usr/glibc-compat/bin "$subpkgdir"/usr/glibc-compat
    cp -a "$srcdir"/usr/glibc-compat/sbin "$subpkgdir"/usr/glibc-compat
}

i18n() {
    depends="$pkgname-bin"
    arch="noarch"
    mkdir -p "$subpkgdir"/usr/glibc-compat
    cp -a "$srcdir"/usr/glibc-compat/share "$subpkgdir"/usr/glibc-compat
}

