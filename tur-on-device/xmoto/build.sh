TERMUX_PKG_HOMEPAGE=https://xmoto.tuxfamily.org/
TERMUX_PKG_DESCRIPTION="A challenging 2D motocross platform game"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.6.3"
TERMUX_PKG_SRCURL=https://github.com/xmoto/xmoto/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=64cb29934660456ec82cebdaa0d3d273a862e10760e8ee80443928d317242484
TERMUX_PKG_DEPENDS="libx11, libjpeg-turbo, libpng, lua54, sdl2, sdl2-mixer, sdl2-net, libcurl, bzip2, libxdg-basedir, sdl2-ttf, glu, game-music-emu, libwavpack"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}
