TERMUX_PKG_HOMEPAGE="https://github.com/t6x/reaver-wps-fork-t6x"
TERMUX_PKG_DESCRIPTION="Reaver performs a brute force attack against an access point’s Wi-Fi Protected Setup pin number."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.6.6-926eb14
TERMUX_PKG_SRCURL=https://codeload.github.com/t6x/reaver-wps-fork-t6x/tar.gz/926eb14143f76bcd24e9aee75279d1227e40e261
TERMUX_PKG_SHA256=1ca4ec5ef243017e5bd6bc9d93cb5c5b79aa24c8ab61880e411c27b8366ffee3
TERMUX_PKG_DEPENDS="libpcap, libnl"
TERMUX_PKG_RECOMMENDS="aircrack-ng"
TERMUX_PKG_BUILD_DEPENDS="aircrack-ng, libpcap, libnl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-libpcap-include=$TERMUX_PREFIX/include
--with-libpcap-lib=$TERMUX_PREFIX/lib
--enable-libnl3
"

termux_step_post_get_source() {
	mv src/* .
	sed -i 's/DESIRED_FLAGS="-Werror-unknown-warning-option -Wno-unused-but-set-variable"/DESIRED_FLAGS="-Wno-unused-but-set-variable"/g' configure
}
