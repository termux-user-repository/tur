TERMUX_PKG_HOMEPAGE="http://lpg.ticalc.org/prj_tilp/"
TERMUX_PKG_DESCRIPTION="Provides libtifiles2 library and headers for TiEmu and TiLP"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="3ls-it <3ls-it@pm.me>"
TERMUX_PKG_VERSION=1.1.7
TERMUX_PKG_SRCURL="https://sourceforge.net/projects/tilp/files/tilp2-linux/tilp2-1.18/libtifiles2-${TERMUX_PKG_VERSION}.tar.bz2"
TERMUX_PKG_SHA256=9ac63b49e97b09b30b37bbc84aeb15fa7967bceb944e56141c5cd5a528acc982
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="glib, libarchive, libticonv"

termux_step_pre_configure() {
		autoreconf -fi
}
