TERMUX_PKG_HOMEPAGE=https://www.flightgear.org/
TERMUX_PKG_DESCRIPTION="SimGear - simulation libraries for FlightGear"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="2024.1.7"
TERMUX_PKG_SRCURL=https://gitlab.com/flightgear/simgear/-/archive/${TERMUX_PKG_VERSION}/simgear-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=bd9f79bbc781a188fcaad893aba67beb45eaaa4ab92e8b0276b608be3f185e0b
TERMUX_PKG_DEPENDS="boost, mesa, openal-soft, openscenegraph, libcurl, c-ares"
TERMUX_PKG_BUILD_DEPENDS="libglvnd-dev, mesa-dev"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	export CPPFLAGS+=" -DXML_POOR_ENTROPY -D_LIBCPP_HAS_NO_COND_CLOCKWAIT"
	export CFLAGS+=" $CPPFLAGS"
	export CXXFLAGS+=" $CPPFLAGS"

	export LDFLAGS+=" -Wl,--no-as-needed,-lOpenSLES,--as-needed"
}
