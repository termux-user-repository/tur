TERMUX_PKG_HOMEPAGE=https://www.redeclipse.net/
TERMUX_PKG_DESCRIPTION="A free, casual arena shooter"
TERMUX_PKG_LICENSE="ZLIB, custom"
TERMUX_PKG_LICENSE_FILE="doc/license.txt, doc/all-licenses.txt"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=2.0.0
TERMUX_PKG_SRCURL=https://github.com/redeclipse/base/releases/download/v${TERMUX_PKG_VERSION}/redeclipse_${TERMUX_PKG_VERSION}_combined.tar.bz2
TERMUX_PKG_SHA256=a35d27368c4f63496e5b41be30c2084f39af38ea2fcdf4d8b0cdc6061b08b32d
TERMUX_PKG_DEPENDS="libenet, sdl2, sdl2-image, sdl2-mixer, zlib, redeclipse-data"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	make -C src/ -j $TERMUX_PKG_MAKE_PROCESSES client server
}

termux_step_make_install() {
	make -C src prefix="$TERMUX_PREFIX" system-install
}
