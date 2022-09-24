TERMUX_PKG_HOMEPAGE=https://github.com/opencoff/fastdd
TERMUX_PKG_DESCRIPTION="Performance-improved dd(1) that simplified in terms of dropping its POSIX semantic of \"block\""
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=0.2.2
TERMUX_PKG_SRCURL=https://github.com/opencoff/fastdd/archive/refs/tags/v"$TERMUX_PKG_VERSION".tar.gz
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_DEPENDS="ncurses"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_MAKE_ARGS="-f GNUmakefile"
TERMUX_PKG_MAKE_INSTALL_TARGET="DESTDIR=$TERMUX_PREFIX/bin"
TERMUX_PKG_BLACKLISTED_ARCHES="arm"

termux_step_configure() {
	true
}

termux_step_post_make_install() {
	install -Dm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README.*
}
