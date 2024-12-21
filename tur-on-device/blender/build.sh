TERMUX_PKG_HOMEPAGE=https://www.blender.org
TERMUX_PKG_DESCRIPTION="A fully integrated 3D graphics creation suite"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1:3.6.16
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://github.com/blender/blender.git
TERMUX_PKG_GIT_BRANCH="v${TERMUX_PKG_VERSION#*:}"

# Blender does not support 32bit
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

TERMUX_PKG_DEPENDS="libpng, libtiff, python, python-pip, python-numpy, openexr, desktop-file-utils, potrace, shared-mime-info, hicolor-icon-theme, glew, openjpeg, freetype, ffmpeg, fftw, alembic, libsndfile, ptex, sdl2, libspnav, openal-soft, opencolorio, libblosc, sse2neon, libandroid-execinfo, brotli, libepoxy, openimageio, pybind11, openvdb, libraw, libpugixml, shaderc"
TERMUX_PKG_BUILD_DEPENDS="subversion, git-lfs"
TERMUX_PKG_PYTHON_COMMON_DEPS="Cython"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DPYTHON_LIBRARY=$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION
-DPYTHON_INCLUDE_DIR=$TERMUX_PREFIX/include/python$TERMUX_PYTHON_VERSION
-DPYTHON_VERSION=$TERMUX_PYTHON_VERSION
-DPYTHON_SITE_PACKAGES=$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION/site-packages
-DPYTHON_EXECUTABLE=$TERMUX_PREFIX/bin/python$TERMUX_PYTHON_VERSION
-DWITH_CYCLES_NATIVE_ONLY=ON
-DWITH_CYCLES_EMBREE=OFF
-DWITH_INSTALL_PORTABLE=OFF
-DWITH_PYTHON_INSTALL=OFF
-DWITH_GHOST_WAYLAND=OFF
-DHAVE_MALLOC_STATS_H=OFF
"

TERMUX_PKG_RM_AFTER_INSTALL="
lib/python$TERMUX_PYTHON_VERSION/
"

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

termux_step_make() {
	# ld.lld: error: undefined symbol: backtrace
	LDFLAGS+=" -landroid-execinfo"
	# ld.lld: error: version script assignment
	LDFLAGS+=" -Wl,--undefined-version"
	ninja -j $(nproc)
}
