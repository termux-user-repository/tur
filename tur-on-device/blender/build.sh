TERMUX_PKG_HOMEPAGE=https://www.blender.org
TERMUX_PKG_DESCRIPTION="A fully integrated 3D graphics creation suite"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@T-Dynamos"
BLENDER_MAJOR_VERSION=4 
BLENDER_MINOR_VERSION=0
BLENDER_ADDONS_COMMIT=92dd274c0bf08ad4786e7dfe715dee327f3ee43f 
_COMMIT=0d7b0045c6795ba5ebd73bc588cb808d85ed10da
_COMMIT_DATE=2023.08.03
TERMUX_PKG_VERSION=${BLENDER_MAJOR_VERSION}.${BLENDER_MINOR_VERSION}-${_COMMIT:0:8}-${_COMMIT_DATE}
TERMUX_PKG_SRCURL=git+https://github.com/blender/blender
TERMUX_PKG_GIT_BRANCH=main 

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
    # Position independent executables are not supported on android
    sed -i "s/no-pie/pie/g" $TERMUX_PKG_SRCDIR/build_files/cmake/platform/platform_unix.cmake
}

termux_step_post_make_install() {
    export MODIR=$TERMUX_PREFIX/share/blender/$BLENDER_MAJOR_VERSION.$BLENDER_MINOR_VERSION/scripts/modules
    curl -L https://github.com/blender/blender-addons/archive/$BLENDER_ADDONS_COMMIT.tar.gz | tar xvz -C $MODIR/
    cp -r $MODIR/blender-addons-$BLENDER_ADDONS_COMMIT/* $MODIR/
    rm -rf $MODIR/blender-addons-$BLENDER_ADDONS_COMMIT
}
