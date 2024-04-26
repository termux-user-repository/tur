TERMUX_PKG_HOMEPAGE=https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm
TERMUX_PKG_DESCRIPTION="Shared library for some missing libm functions of Bionic Libc"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_SRCURL=(https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm/upstream-freebsd/lib/msun/src/math_private.h
				https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm/upstream-freebsd/lib/msun/src/s_clog.c
				https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm/upstream-freebsd/lib/msun/src/s_clogf.c
				https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm/upstream-freebsd/lib/msun/src/s_cpow.c
				https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm/upstream-freebsd/lib/msun/src/s_cpowf.c
				https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm/fpmath.h)
TERMUX_PKG_SHA256=(SKIP_CHECKSUM
				SKIP_CHECKSUM
				SKIP_CHECKSUM
				SKIP_CHECKSUM
				SKIP_CHECKSUM
				SKIP_CHECKSUM)
TERMUX_PKG_VERSION=0.1
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

# Files are taken from the Bionic libc repo.
# *.c/math_private.h: https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm/upstream-freebsd/lib/msun/src/
# fpmath.h: https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm/fpmath.h
termux_step_get_source() {
	mkdir -p $TERMUX_PKG_SRCDIR
	cd $TERMUX_PKG_SRCDIR

	for url in "${TERMUX_PKG_SRCURL[@]}"; do
		curl "$url?format=text" | base64 -d > "$(basename $url)"
	done

	sed -i "s/#include <machine\/endian.h>/#include <endian.h>/" math_private.h
}

termux_step_make() {
	$CC $CFLAGS -I$TERMUX_PKG_SRCDIR -c $TERMUX_PKG_SRCDIR/s_c{log,pow}{,f}.c
	$CC $LDFLAGS -shared s_c{log,pow}{,f}.o -o libandroid-mathlib.so
	$AR rcu libandroid-mathlib.a s_c{log,pow}{,f}.o
	cp -f $TERMUX_PKG_BUILDER_DIR/LICENSE $TERMUX_PKG_SRCDIR
}

termux_step_make_install() {
	install -Dm600 libandroid-mathlib.a $TERMUX_PREFIX/lib/libandroid-mathlib.a
	install -Dm600 libandroid-mathlib.so $TERMUX_PREFIX/lib/libandroid-mathlib.so
}
