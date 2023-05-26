TERMUX_PKG_HOMEPAGE=https://pygame.org/
TERMUX_PKG_DESCRIPTION="pygame is a python game library"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.4.0
TERMUX_PKG_SRCURL=https://github.com/pygame/pygame/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=7d7efd65812fa0d8a83a92afd22116dee7997a38bd7126097230ae1dd6dec4b8
TERMUX_PKG_DEPENDS="x11-repo, freetype, portmidi, python, sdl2, sdl2-image, sdl2-mixer, sdl2-ttf"
TERMUX_PKG_BUILD_DEPENDS="xorgproto"
TERMUX_PKG_PYTHON_BUILD_DEPS="wheel"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

termux_step_pre_configure() {
	export CFLAGS+=" -Wno-error=incompatible-function-pointer-types"
	export CPPFLAGS+=" -Wno-error=incompatible-function-pointer-types"
	export CXXFLAGS+=" -Wno-error=incompatible-function-pointer-types"

	export PATH="$PATH:$TERMUX_PREFIX/bin"

	LDFLAGS+=" -lpython${TERMUX_PYTHON_VERSION}"
}
