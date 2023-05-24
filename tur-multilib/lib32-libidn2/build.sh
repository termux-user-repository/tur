TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/libidn/#libidn2
TERMUX_PKG_DESCRIPTION="Free software implementation of IDNA2008, Punycode and TR46"
TERMUX_PKG_LICENSE="LGPL-3.0, GPL-2.0, GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.3.4
TERMUX_PKG_SRCURL=https://mirrors.kernel.org/gnu/libidn/libidn2-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=93caba72b4e051d1f8d4f5a076ab63c99b77faee019b72b9783b267986dbb45f
TERMUX_PKG_DEPENDS="lib32-libandroid-support, lib32-libiconv, lib32-libunistring"

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
