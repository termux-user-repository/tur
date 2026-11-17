TERMUX_PKG_HOMEPAGE=http://www.openscenegraph.org
TERMUX_PKG_DESCRIPTION="The OpenSceneGraph is an open source high performance 3D graphics toolkit, used by application developers in fields such as visual simulation, games, virtual reality, scientific visualization and modelling. (Flightgear Fork)"
TERMUX_PKG_LICENSE="LGPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=2024
TERMUX_PKG_SRCURL=https://gitlab.com/flightgear/openscenegraph/-/archive/release/$TERMUX_PKG_VERSION-build/openscenegraph-release-$TERMUX_PKG_VERSION-build.tar.bz2
TERMUX_PKG_SHA256=8a32ae3d4448b37ae0263da25663d939f8c20d3bf7ad58f58a1ce4ab146a0e7d
TERMUX_PKG_DEPENDS="freetype, sdl, gdal, libasio, libvncserver"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS='
-DANDROID=false
-DLINUX=true
-DUNIX=true
-DCMAKE_SYSTEM_NAME=Linux
-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE=0
'

termux_step_pre_configure() {
	export TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DMATH_LIBRARY=$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_API_LEVEL/libm.so"
	export CXXFLAGS+=" -std=c++11"
	export LDFLAGS+=" -lXinerama"
}
