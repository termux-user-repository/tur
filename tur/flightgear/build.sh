TERMUX_PKG_HOMEPAGE=https://www.flightgear.org
TERMUX_PKG_DESCRIPTION="Free open-source flight simulator"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2024.1.7
TERMUX_PKG_SRCURL=https://gitlab.com/flightgear/flightgear/-/archive/${TERMUX_PKG_VERSION}/flightgear-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=af61845fd1a260496200e1c48162a9c75b4e8fbe70a8fa4520f2251dc7ee958b
TERMUX_PKG_DEPENDS="boost, mesa, openscenegraph, plib, simgear, libandroid-execinfo, openal-soft, qt6-qtbase, qt6-qtdeclarative, qt6-qtsvg"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_GROUPS="games"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS='
-DCHECK_FOR_QT6=ON
-DCMAKE_SYSTEM_NAME=Linux
-DCROSS_COMPILING=ON
-DWITH_FGPANEL=ON
-DSYSTEM_SQLITE=ON
'

termux_step_pre_configure() {
	export LDFLAGS+=" -landroid-execinfo"
}
