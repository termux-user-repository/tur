TERMUX_PKG_HOMEPAGE=https://github.com/JuliaMath/openspecfun
TERMUX_PKG_DESCRIPTION="A collection of special mathematical functions"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.5.7
TERMUX_PKG_SRCURL=https://github.com/JuliaMath/openspecfun/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=6209413bc5291f4aad68903fc7851a18ddc94d3432ee0dd1b69e02dc370ece2a
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_pre_configure() {
	_setup_toolchain_ndk_gcc_11
	_override_configure_cmake_for_gcc
}
