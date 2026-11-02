TERMUX_PKG_HOMEPAGE=https://github.com/SearchAndRescue2/sar2
TERMUX_PKG_DESCRIPTION="Search and Rescue II helicopter simulator"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=2.6.0
TERMUX_PKG_SRCURL=https://github.com/SearchAndRescue2/sar2/archive/refs/tags/v2.6.0.tar.gz
TERMUX_PKG_SHA256=d64f41549733c4e31c0c35082b52087166039d8f4fbae00aa3dcb999f976ff7f
TERMUX_PKG_DEPENDS="glu, libglvnd, libvorbis, libx11, libxext, libxpm, libxxf86vm, openal-soft, openalut, sdl2 | sdl2-compat, searchandrescue2-data"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_GROUPS="games"

termux_step_post_get_source() {
	bzip2 -df man/sar2.6.bz2
}

termux_step_make() {
	scons -j$TERMUX_PKG_MAKE_PROCESSES
}

termux_step_make_install() {
	scons install
}
