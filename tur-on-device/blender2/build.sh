TERMUX_PKG_HOMEPAGE=https://www.blender.org
TERMUX_PKG_DESCRIPTION="A fully integrated 3D graphics creation suite"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@T-Dynamos"
BLENDER_MAJOR_VERSION=2.79
BLENDER_MINOR_VERSION=b
_COMMIT=f4dc9f9d68bddaa206b692e1d077d1a1f2bb1528 
_COMMIT_DATE=2018.03.22
TERMUX_PKG_VERSION=${BLENDER_MAJOR_VERSION}.${BLENDER_MINOR_VERSION}-${_COMMIT:0:8}-${_COMMIT_DATE}
TERMUX_PKG_SRCURL=git+https://github.com/blender/blender
TERMUX_PKG_GIT_BRANCH=v2.79b

# Blender does not support 32bit
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

TERMUX_PKG_DEPENDS="libpng, libtiff, python, python-pip, python-numpy, openexr, desktop-file-utils, potrace, shared-mime-info, hicolor-icon-theme, glew, openjpeg, freetype, ffmpeg, fftw, alembic, libsndfile, ptex, sdl2, libspnav, openal-soft, opencolorio, libblosc, sse2neon, libandroid-execinfo, brotli, libepoxy, openimageio, pybind11, openvdb, libraw, libpugixml"
TERMUX_PKG_BUILD_DEPENDS="subversion"
TERMUX_PKG_REVISION=1
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

termux_step_pre_configure(){
    # ld.lld: error: undefined symbol: backtrace
    LDFLAGS+=" -landroid-execinfo"
}
