TERMUX_PKG_HOMEPAGE="https://github.com/KelvinShadewing/brux-gdk"
TERMUX_PKG_DESCRIPTION="Brux Game Runtime Environment"
TERMUX_PKG_LICENSE="AGPL-3.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
_COMMIT=d8e73aa44d39029421738a1606ac78c79b98d2c1
TERMUX_PKG_VERSION=2026.01.07
TERMUX_PKG_SRCURL="https://github.com/KelvinShadewing/brux-gdk/archive/${_COMMIT}.tar.gz"
TERMUX_PKG_SHA256=06d2ee854c9f92027d313c49100439483bf124f22b2d5716c66d6a04c1a0c342
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="libc++, libcurl, libphysfs, sdl2, sdl2-gfx, sdl2-image, sdl2-mixer, sdl2-net, simplesquirrel, squirrel3"

termux_step_pre_configure() {
	TERMUX_PKG_SRCDIR+="/rte"
}
