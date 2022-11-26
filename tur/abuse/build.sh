TERMUX_PKG_HOMEPAGE=https://github.com/Xenoveritas/abuse
TERMUX_PKG_DESCRIPTION="A dark 2D side-scrolling platform game"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="\
COPYING
COPYING.GPL
COPYING.WTFPL"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.9.1"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/Xenoveritas/abuse/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=73d41d11a1d3681d32a2073182a4132fe4cf92bf45db344b516aa915259bee09
TERMUX_PKG_DEPENDS="sdl2, sdl2-mixer"
TERMUX_PKG_AUTO_UPDATE=true

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_pre_configure() {
	_setup_toolchain_ndk_gcc_11
	_override_configure_cmake_for_gcc
	LDFLAGS+=" -Wl,-rpath-link=$TERMUX_PREFIX/lib"
}
