TERMUX_PKG_HOMEPAGE=https://github.com/dreamworksanimation/openvdb
TERMUX_PKG_DESCRIPTION="A large suite of tools for the efficient storage and manipulation of sparse volumetric data discretized on three-dimensional grids"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
# 11.0.0 is not supported for OpenImageIO
# https://github.com/AcademySoftwareFoundation/OpenImageIO/pull/4023
TERMUX_PKG_VERSION=10.0.1
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL=https://github.com/AcademySoftwareFoundation/openvdb/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=887a3391fbd96b20c77914f4fb3ab4b33d26e5fc479aa036d395def5523c622f
TERMUX_PKG_DEPENDS="boost, libblosc, libtbb, zlib"
TERMUX_PKG_BUILD_DEPENDS="mesa, glfw, glu"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DUSE_NUMPY=OFF
-DUSE_LOG4CPLUS=OFF
-DOPENVDB_BUILD_PYTHON_MODULE=OFF
-DOPENVDB_BUILD_DOCS=OFF
-DOPENVDB_BUILD_UNITTESTS=OFF
"
