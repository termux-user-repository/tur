TERMUX_PKG_HOMEPAGE=https://github.com/SearchAndRescue2/sar2
TERMUX_PKG_DESCRIPTION="Search and Rescue II helicopter simulator"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=2.6.0
TERMUX_PKG_SRCURL=https://github.com/SearchAndRescue2/sar2/archive/refs/tags/v2.6.0.tar.gz
TERMUX_PKG_SHA256=d64f41549733c4e31c0c35082b52087166039d8f4fbae00aa3dcb999f976ff7f
TERMUX_PKG_DEPENDS="openalut, mesa, openal-soft, libvorbis, sdl2 | sdl2-compat, libxpm, libxmu, glu, searchandrescue2-data"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_GROUPS="games"

termux_step_pre_configure() {
	export LDFLAGS+=" -landroid-spawn"
	export LDFLAGS+=" -Wl,--no-as-needed,-lOpenSLES,--as-needed"
}

termux_step_make() {
	scons --clean
	scons prefix=$TERMUX_PREFIX
		LINKFLAGS="$LDFLAGS"
}

termux_step_make_install() {
	scons install \
		PREFIX=$TERMUX_PREFIX \
		--prefix=$TERMUX_PREFIX
		LINKFLAGS="$LDFLAGS"
}
