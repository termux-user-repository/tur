TERMUX_PKG_HOMEPAGE=https://www.flightgear.org/
TERMUX_PKG_DESCRIPTION="SimGear - simulation libraries for FlightGear"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="2024.1.3"
TERMUX_PKG_SRCURL=http://gitlab.com/flightgear/simgear/-/archive/${TERMUX_PKG_VERSION}/simgear-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=d395dcca2aa3875c5468f285f23d053e41e5e8d92576e16fd9801d685441115d
TERMUX_PKG_DEPENDS="boost, mesa, openal-soft, openscenegraph, libcurl, c-ares"
TERMUX_PKG_BUILD_DEPENDS="libglvnd-dev, mesa-dev"

termux_step_pre_configure() {
	export CPPFLAGS+=" -DXML_POOR_ENTROPY -D_LIBCPP_HAS_NO_COND_CLOCKWAIT"
	export CFLAGS+=" $CPPFLAGS"
	export CXXFLAGS+=" $CPPFLAGS"

	export LDFLAGS+=" -Wl,--no-as-needed,-lOpenSLES,--as-needed"
}
