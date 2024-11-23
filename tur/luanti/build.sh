TERMUX_PKG_HOMEPAGE=https://www.luanti.org
TERMUX_PKG_DESCRIPTION="An open source voxel game engine."
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1:5.10.0
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/minetest/minetest/archive/refs/tags/${TERMUX_PKG_VERSION:2}.zip
TERMUX_PKG_SHA256=e74e994c0f1b188d60969477f553ad83b8ce20ee1e0e2dcd068120189cb0f56c
TERMUX_PKG_AUTO_UPDATE=true
# incomplete depends, i dont have time yet to write the perfect depends for this
TERMUX_PKG_DEPENDS="sdl2, libc++, openal-soft, libvorbis, libsqlite, freetype, libpng, libcurl, libandroid-spawn"

termux_step_pre_configure() {
	export LDFLAGS+=" -landroid-spawn"
}
