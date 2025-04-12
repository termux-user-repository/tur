TERMUX_PKG_HOMEPAGE=https://www.flightgear.org/
TERMUX_PKG_DESCRIPTION="SimGear - simulation libraries for FlightGear"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="2024.1.1"
TERMUX_PKG_SRCURL=https://gitlab.com/flightgear/simgear/-/archive/v${TERMUX_PKG_VERSION}/simgear-v${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=b75d3940d923a46c445c9afa6f8eb09f6a944ff23c4b546e72ba75fb5482a794
TERMUX_PKG_DEPENDS="boost, mesa, openal-soft, openscenegraph, libcurl"
TERMUX_PKG_BUILD_DEPENDS="libglvnd-dev, mesa-dev"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS='
-DCMAKE_C_FLAGS="-DXML_POOR_ENTROPY"
-DCMAKE_CXX_FLAGS="-DXML_POOR_ENTROPY"
'

termux_step_pre_configure() {
	export LDFLAGS+=" -Wl,--no-as-needed,-lOpenSLES,--as-needed"
}