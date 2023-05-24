TERMUX_PKG_HOMEPAGE=https://gmplib.org/
TERMUX_PKG_DESCRIPTION="Library for arbitrary precision arithmetic"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=6.2.1
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://mirrors.kernel.org/gnu/gmp/gmp-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2
TERMUX_PKG_DEPENDS="lib32-libc++"

source $TERMUX_SCRIPTDIR/common-files/setup_multilib_toolchain.sh

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-cxx
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

	# the cxx tests fail because it won't link properly without this
	CXXFLAGS+=" -L$TERMUX_PREFIX/lib/$TUR_MULTILIB_ARCH_TRIPLE"
}
