TERMUX_PKG_HOMEPAGE=https://pygame.org/
TERMUX_PKG_DESCRIPTION="pygame is a python game library"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.6.1"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/pygame/pygame/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=6a5dd68af93a11ba6eb35c971fa220bf253cebf63b1f54cbe697b30fae9c7c72
TERMUX_PKG_DEPENDS="x11-repo, freetype, portmidi, python, sdl2, sdl2-image, sdl2-mixer, sdl2-ttf"
TERMUX_PKG_BUILD_DEPENDS="xorgproto"
TERMUX_PKG_PYTHON_BUILD_DEPS="'Cython>=3.0', wheel"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

termux_step_pre_configure() {
	export PATH="$PATH:$TERMUX_PREFIX/bin"
	LDFLAGS+=" -lm"
}
