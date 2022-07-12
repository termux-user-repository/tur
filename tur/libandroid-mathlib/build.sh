TERMUX_PKG_HOMEPAGE=https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm
TERMUX_PKG_DESCRIPTION="Shared library for some missing libm functions of Bionic Libc"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.1
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

# Files are taken from the Bionic libc repo. 
# *.c/math_private.h: https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm/upstream-freebsd/lib/msun/src/
# fpmath.h: https://android.googlesource.com/platform/bionic/+/refs/heads/master/libm/fpmath.h
termux_step_make() {
	$CC $CFLAGS -I$TERMUX_PKG_BUILDER_DIR -c $TERMUX_PKG_BUILDER_DIR/s_c{log,pow}{,f}.c
	$CC $LDFLAGS -shared s_c{log,pow}{,f}.o -o libandroid-mathlib.so
	$AR rcu libandroid-mathlib.a s_c{log,pow}{,f}.o
	cp -f $TERMUX_PKG_BUILDER_DIR/LICENSE $TERMUX_PKG_SRCDIR
}

termux_step_make_install() {
	install -Dm600 libandroid-mathlib.a $TERMUX_PREFIX/lib/libandroid-mathlib.a
	install -Dm600 libandroid-mathlib.so $TERMUX_PREFIX/lib/libandroid-mathlib.so
}
