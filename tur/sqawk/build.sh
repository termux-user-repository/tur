TERMUX_PKG_HOMEPAGE=https://github.com/dbohdan/sqawk
TERMUX_PKG_DESCRIPTION="Manipulate csv/tsv/json data using SQL in an AWK-like fashion (sqlite-tcl as backend with db dump)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@flosnvjx, @termux-user-repository"
TERMUX_PKG_VERSION=0.23.1
TERMUX_PKG_SRCURL=https://github.com/dbohdan/sqawk/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=e689a776d94f6e3bd735b6a96ef0b17e2b88a81541b6b7edb67132f71ddaa99c
TERMUX_PKG_DEPENDS="tcl, tcllib, libsqlite-tcl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	make prefix=$TERMUX_PREFIX install
	install -dm700 $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
	cp -r examples/ $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
	install -pm600 README.* -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
}
