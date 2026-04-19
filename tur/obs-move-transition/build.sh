TERMUX_PKG_HOMEPAGE="https://github.com/exeldro/obs-move-transition"
TERMUX_PKG_DESCRIPTION="Plugin for OBS Studio to move sources to a new position during scene transition"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@lumaparalax"
TERMUX_PKG_VERSION="3.2.1"
TERMUX_PKG_SRCURL="git+https://github.com/exeldro/obs-move-transition.git"
TERMUX_PKG_GIT_BRANCH="${TERMUX_PKG_VERSION}"
TERMUX_PKG_DEPENDS="obs-studio"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_CXX_SCAN_FOR_MODULES=OFF
-Dobs_DIR=${TERMUX_PREFIX}/lib/cmake/libobs
"

termux_step_pre_configure() {
	LDFLAGS+=" -lm"
}

termux_step_create_debscripts() {
	echo "X-Display-Name: Move Transition" >> control
}
