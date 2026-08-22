TERMUX_PKG_HOMEPAGE="http://lpg.ticalc.org/prj_tilp/"
TERMUX_PKG_DESCRIPTION="Provides libticonv libraries and headers for TiEmu and TiLP"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="3ls-it <3ls-it@pm.me>"
TERMUX_PKG_VERSION=1.1.5
TERMUX_PKG_SRCURL="https://sourceforge.net/projects/tilp/files/tilp2-linux/tilp2-1.18/libticonv-${TERMUX_PKG_VERSION}.tar.bz2"
TERMUX_PKG_SHA256=316da6a73bf26b266dd23443882abc4c9fe7013edc3a53e5e301d525c2060878
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="glib"

termux_step_pre_configure() {
		autoreconf -fi
}
