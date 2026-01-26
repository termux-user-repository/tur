TERMUX_PKG_HOMEPAGE=https://gitlab.com/thp/numptyphysics
TERMUX_PKG_DESCRIPTION="Crayon based physics puzzle game"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=0.3.10
TERMUX_PKG_SRCURL=https://gitlab.com/thp/numptyphysics/-/archive/0.3.10/numptyphysics-0.3.10.tar.bz2
TERMUX_PKG_SHA256=f863ba1bae51934bef31984e40ce1b3dbd82672c0bcd705b50185dd40c4f3618
TERMUX_PKG_DEPENDS="libtinyxml2, fontconfig, sdl2-image, sdl2-ttf"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_GROUPS="games"

termux_step_pre_configure() {
	# Version is determined by git, but we don't have git repo here
	export VERSION=$TERMUX_PKG_VERSION
}

termux_step_make_install() {
	make install PREFIX=$TERMUX_PREFIX
	make install_freedesktop PREFIX=$TERMUX_PREFIX
}
