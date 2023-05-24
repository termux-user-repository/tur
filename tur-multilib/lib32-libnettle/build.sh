TERMUX_PKG_HOMEPAGE=https://www.lysator.liu.se/~nisse/nettle/
TERMUX_PKG_DESCRIPTION="Cryptographic library that is designed to fit easily in more or less any context"
TERMUX_PKG_LICENSE="GPL-2.0, LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=3.9
TERMUX_PKG_SRCURL=https://mirrors.kernel.org/gnu/nettle/nettle-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=0ee7adf5a7201610bb7fe0acbb7c9b3be83be44904dd35ebbcd965cd896bfeaa
TERMUX_PKG_DEPENDS="lib32-libgmp"

source $TERMUX_SCRIPTDIR/common-files/setup_multilib_toolchain.sh

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--host=$TUR_MULTILIB_ARCH_TRIPLE
--exec-prefix=$TERMUX_PREFIX/$TUR_MULTILIB_ARCH_TRIPLE
--includedir=$TERMUX_PREFIX/$TUR_MULTILIB_ARCH_TRIPLE/include
--libdir=$TERMUX_PREFIX/$TUR_MULTILIB_ARCH_TRIPLE/lib
"

TERMUX_PKG_RM_AFTER_INSTALL="
share/info
share/man
"

termux_step_pre_configure() {
	_setup_multilib_toolchain
}
