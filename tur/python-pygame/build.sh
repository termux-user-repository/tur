TERMUX_PKG_HOMEPAGE=https://pygame.org/
TERMUX_PKG_DESCRIPTION="pygame is a python game library"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.5.1"
TERMUX_PKG_SRCURL=https://github.com/pygame/pygame/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=f29d5ca72ec487df8f5f19169d66e6e5cecfcdb841c28b3c711cfd4f263a672a
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
