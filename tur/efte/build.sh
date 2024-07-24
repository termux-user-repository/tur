TERMUX_PKG_HOMEPAGE=http://sourceforge.net/projects/efte
TERMUX_PKG_DESCRIPTION='Advanced lightweight configurable editor'
# LICENSE: GPL-2.0, Artistic
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING, Artistic"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.1
TERMUX_PKG_SRCURL=http://downloads.sourceforge.net/sourceforge/efte/efte-$TERMUX_PKG_VERSION.tar.bz2
TERMUX_PKG_SHA256=b71b9301dc781555bd9f4c73d7d81eb92701ccd5119b17da9b86ede402d31e16
TERMUX_PKG_DEPENDS="desktop-file-utils, libxpm"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBUILD_X=ON
-DBUILD_CONSOLE=OFF
-DUSE_LOCALE=OFF
"
TERMUX_PKG_HOSTBUILD=true

termux_step_host_build() {
	termux_setup_cmake
	cmake "$TERMUX_PKG_SRCDIR" -DBUILD_X=OFF -DBUILD_CONSOLE=OFF
	make -j $TERMUX_PKG_MAKE_PROCESSES bin2c
}

termux_step_pre_configure() {
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/src:$PATH"
}
