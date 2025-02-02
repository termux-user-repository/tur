TERMUX_PKG_HOMEPAGE=http://www.openimageio.org/
TERMUX_PKG_DESCRIPTION="A library for reading and writing images, including classes, utilities, and applications"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_LICENSE_FILE="LICENSE.md"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.5.6.0
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL=https://github.com/OpenImageIO/oiio/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=bcfced40a25ef8576383b44d8bbe3732aa2b8efc7b8614482783d6f90378d307
TERMUX_PKG_DEPENDS="openexr, boost, openjpeg, glew, libtiff, opencolorio, libwebp, libpng, libheif, libhdf5, freetype, python, ffmpeg, opencv, ptex-static, qt6-qtbase, pybind11, libraw, libjpeg-turbo-static, libtbb, dcmtk, openvdb"
TERMUX_PKG_BUILD_DEPENDS="boost-headers, mesa, fontconfig, libxrender, robin-map, libpugixml"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DUSE_PYTHON=ON
-DPYTHON_VERSION=$TERMUX_PYTHON_VERSION
-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF
-DOIIO_NO_NEON=ON
-DBUILD_FMT_FORCE=ON
"
