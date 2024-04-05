TERMUX_PKG_HOMEPAGE=https://www.blender.org
TERMUX_PKG_DESCRIPTION="A fully integrated 3D graphics creation suite"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@T-Dynamos"
BLENDER_MAJOR_VERSION=4 
BLENDER_MINOR_VERSION=1
_COMMIT=6b9655eba976ab907d37964883008c3291733f01
_COMMIT_DATE=2024.04.04
TERMUX_PKG_VERSION=${BLENDER_MAJOR_VERSION}.${BLENDER_MINOR_VERSION}-${_COMMIT:0:8}-${_COMMIT_DATE}
TERMUX_PKG_SRCURL=git+https://github.com/blender/blender
TERMUX_PKG_GIT_BRANCH=blender-v4.1-release

# Blender does not support 32bit
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

TERMUX_PKG_DEPENDS="libpng, libtiff, python, python-pip, python-numpy, openexr, desktop-file-utils, potrace, shared-mime-info, hicolor-icon-theme, glew, openjpeg, freetype, ffmpeg, fftw, alembic, libsndfile, ptex, sdl2, libspnav, openal-soft, opencolorio, libblosc, sse2neon, libandroid-execinfo, brotli, libepoxy, openimageio, pybind11, openvdb, libraw, libpugixml, shaderc"
TERMUX_PKG_BUILD_DEPENDS="subversion, git-lfs"
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

TERMUX_PKG_RM_AFTER_INSTALL="
lib/python$TERMUX_PYTHON_VERSION/__pycache__/*
lib/python$TERMUX_PYTHON_VERSION/site-packages/pip/_vendor/distro/__pycache__/*
bin/c*
bin/normalizer
"

termux_step_post_get_source() {
    git fetch --unshallow
    git checkout $_COMMIT
    local version="$(git log -1 --format=%cs | sed 's/-/./g')"
    if [ "$version" != "$_COMMIT_DATE" ]; then
        echo -n "ERROR: The specified version \"$TERMUX_PKG_VERSION\""
        echo " is different from what is expected to be: \"$version\""
        return 1
    fi
}

termux_step_pre_configure(){
    if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
        termux_error_exit "This package doesn't support cross-compiling."
    fi 
    # ld.lld: error: undefined symbol: backtrace
    LDFLAGS+=" -landroid-execinfo"
    # ld.lld: error: version script assignment 
    LDFLAGS+=" -Wl,--undefined-version"
    # Position independent executables are not supported on android
    sed -i "s/no-pie/pie/g" $TERMUX_PKG_SRCDIR/build_files/cmake/platform/platform_unix.cmake
    # Fetch addons
    local _ARCH
    if [ "$TERMUX_ARCH" = "aarch64" ]; then
      _ARCH="arm64"
    else
      _ARCH=$TERMUX_ARCH
    fi
    python3 ./build_files/utils/make_update.py --architecture $_ARCH
}
