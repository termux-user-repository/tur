TERMUX_PKG_HOMEPAGE=https://www.flightgear.org
TERMUX_PKG_DESCRIPTION="Free open-source flight simulator"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2024.1.3
TERMUX_PKG_SRCURL=https://gitlab.com/flightgear/flightgear/-/archive/${TERMUX_PKG_VERSION}/flightgear-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=9131c5b3441804b31e213477ed07f8bcba9df9382acc5e9ce07b33ebc14a800a
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
