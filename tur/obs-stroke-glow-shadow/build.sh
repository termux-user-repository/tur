TERMUX_PKG_HOMEPAGE="https://github.com/FiniteSingularity/obs-stroke-glow-shadow"
TERMUX_PKG_DESCRIPTION="Efficient Stroke, Glow, and Shadow filter for OBS Studio"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@lumaparalax"
TERMUX_PKG_VERSION="1.5.3"
TERMUX_PKG_SRCURL="git+https://github.com/FiniteSingularity/obs-stroke-glow-shadow.git"
TERMUX_PKG_GIT_BRANCH="v${TERMUX_PKG_VERSION}"
TERMUX_PKG_DEPENDS="obs-studio"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_CXX_SCAN_FOR_MODULES=OFF
-Dobs_DIR=${TERMUX_PREFIX}/lib/cmake/libobs
"

termux_step_pre_configure() {
	LDFLAGS+=" -lm"
}

termux_step_create_debscripts() {
	echo "X-Display-Name: Stroke, Glow, Shadow" >> control
}
