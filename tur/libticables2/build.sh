TERMUX_PKG_HOMEPAGE="http://lpg.ticalc.org/prj_tilp/"
TERMUX_PKG_DESCRIPTION="Provides libticables2 library and headers for TiEmu and TiLP"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="3ls-it <3ls-it@pm.me>"
TERMUX_PKG_VERSION=1.3.5
TERMUX_PKG_SRCURL="https://sourceforge.net/projects/tilp/files/tilp2-linux/tilp2-1.18/libticables2-${TERMUX_PKG_VERSION}.tar.bz2"
TERMUX_PKG_SHA256=0c6fb6516e72ccab081ddb3aecceff694ed93aec689ddd2edba9c7c7406c4522
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="glib, libandroid-shmem, libusb"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-libusb10
"

termux_step_pre_configure() {
		autoreconf -fi
		LDFLAGS+=" -landroid-shmem"
}

