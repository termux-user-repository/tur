TERMUX_PKG_HOMEPAGE=https://www.blender.org
TERMUX_PKG_DESCRIPTION="A fully integrated 3D graphics creation suite"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@T-Dynamos"
BLENDER_MAJOR_VERSION=3 
BLENDER_MINOR_VERSION=6
BLENDER_VERSION_STAGE=alpha
TERMUX_PKG_REVISION=2
TERMUX_PKG_VERSION=${BLENDER_MAJOR_VERSION}.${BLENDER_MINOR_VERSION}-${BLENDER_VERSION_STAGE}
TERMUX_PKG_SRCURL=git+https://github.com/blender/blender
TERMUX_PKG_GIT_BRANCH=main

# Blender does not support 32bit
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

TERMUX_PKG_DEPENDS="libpng, libtiff, python, python-pip, python-numpy, openexr, desktop-file-utils, potrace, shared-mime-info, hicolor-icon-theme, glew, openjpeg, freetype, ffmpeg, fftw, alembic, libsndfile, ptex, sdl2, libspnav, openal-soft, opencolorio, libblosc, sse2neon, libandroid-execinfo, brotli, libepoxy, openimageio, pybind11, openvdb, libraw, libpugixml"
TERMUX_PKG_BUILD_DEPENDS="subversion"
TERMUX_PKG_PYTHON_COMMON_DEPS="requests, zstandard, Cython"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DPYTHON_LIBRARY=$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION
-DPYTHON_INCLUDE_DIR=$TERMUX_PREFIX/include/python$TERMUX_PYTHON_VERSION
-DPYTHON_VERSION=3.11
-DPYTHON_SITE_PACKAGES=$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION/site-packages
-DPYTHON_EXECUTABLE=$TERMUX_PREFIX/bin/python$TERMUX_PYTHON_VERSION
-DWITH_CYCLES_NATIVE_ONLY=ON
-DWITH_CYCLES_EMBREE=OFF
-DWITH_INSTALL_PORTABLE=OFF
-DWITH_PYTHON_INSTALL=OFF
-DWITH_GHOST_WAYLAND=OFF
"

TERMUX_PKG_RM_AFTER_INSTALL="
lib/python$TERMUX_PYTHON_VERSION/__pycache__/*
lib/python$TERMUX_PYTHON_VERSION/site-packages/pip/_vendor/distro/__pycache__/*
bin/c*
bin/normalizer
"

termux_step_pre_configure(){
    # ld.lld: error: undefined symbol: backtrace
    LDFLAGS+=" -landroid-execinfo"
    # Position independent executables are not supported on android
    sed -i "s/no-pie/pie/g" $TERMUX_PKG_SRCDIR/build_files/cmake/platform/platform_unix.cmake
}
