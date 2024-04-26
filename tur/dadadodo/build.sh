TERMUX_PKG_HOMEPAGE=https://www.jwz.org/dadadodo
TERMUX_PKG_DESCRIPTION="A program that analyses texts for word probabilities, and then generates random sentences based on that"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.04"
TERMUX_PKG_SRCURL=https://www.jwz.org/dadadodo/dadadodo-1.04.tar.gz
TERMUX_PKG_SHA256=2e0ebb90951c46ff8823dfeca0c9402ce4576b31dd8bc4b2740a951aebb8fcdf
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	if [ ! -e LICENSE ]; then
		sed 11q dadadodo.c > LICENSE
	fi
}

termux_step_make() {
	make CC="$CC" CFLAGS="$CFLAGS $CPPFLAGS" LDFLAGS="$LDFLAGS"
}

termux_step_make_install() {
	install -D -m755 dadadodo $TERMUX_PREFIX/bin/dadadodo
}
