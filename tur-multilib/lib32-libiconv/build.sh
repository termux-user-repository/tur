TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/libiconv/
TERMUX_PKG_DESCRIPTION="An implementation of iconv()"
TERMUX_PKG_LICENSE="LGPL-2.1, GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.17
TERMUX_PKG_SRCURL=https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=8f74213b56238c85a50a5329f77e06198771e70dd9a739779f4c02f65d971313

source $TERMUX_SCRIPTDIR/common-files/setup_multilib_toolchain.sh

# Enable extra encodings (such as CP437) needed by some programs:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-extra-encodings
--host=$TUR_MULTILIB_ARCH_TRIPLE
--exec-prefix=$TERMUX_PREFIX/$TUR_MULTILIB_ARCH_TRIPLE
--includedir=$TERMUX_PREFIX/$TUR_MULTILIB_ARCH_TRIPLE/include
--libdir=$TERMUX_PREFIX/$TUR_MULTILIB_ARCH_TRIPLE/lib
"

TERMUX_PKG_RM_AFTER_INSTALL="
share/doc/iconv*
share/info
share/man
"

termux_step_pre_configure() {
	_setup_multilib_toolchain
}
