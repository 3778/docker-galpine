# GAlpine
> _GNU C Library compatibility layer for Alpine Linux_

GAlpine is an Alpine Linux adaptation that allows it to run packages that
depend on dynamic linking with the GNU C Library. This works by installing
`glibc` to the prefix `/usr/glibc` as a special `.apk` package, that is rigged
with an apk trigger modifies the linker configuration giving preference to
`glibc` only when packages are installed to certain directories, allowing
`musl` and `glibc` to work side-by-side.

