TERMUX_PKG_HOMEPAGE="http://lpg.ticalc.org/prj_tilp/"
TERMUX_PKG_DESCRIPTION="Provides libticalcs2 library and headers for TiEmu and TiLP"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="3ls-it <3ls-it@pm.me>"
TERMUX_PKG_VERSION=1.1.9
TERMUX_PKG_SRCURL="https://sourceforge.net/projects/tilp/files/tilp2-linux/tilp2-1.18/libticalcs2-${TERMUX_PKG_VERSION}.tar.bz2"
TERMUX_PKG_SHA256=76780788bc309b647f97513d38dd5f01611c335a72855e0bd10c7bdbf2e38921
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="gettext, glib, libticonv, libticables2, libtifiles2"

termux_step_pre_configure() {
		autoreconf -fi
}
