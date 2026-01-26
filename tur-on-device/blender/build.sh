TERMUX_PKG_HOMEPAGE=https://www.blender.org
TERMUX_PKG_DESCRIPTION="A fully integrated 3D graphics creation suite (legacy version)"
# Blender website recommends distributing binaries under "GPL-3.0-or-later" license
# https://www.blender.org/about/license/
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1:3.6.23"
TERMUX_PKG_REVISION=7
TERMUX_PKG_SRCURL=git+https://projects.blender.org/blender/blender
# Blender does not support 32-bit
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_DEPENDS="alembic, boost, brotli, clang, desktop-file-utils, draco, ffmpeg7, fftw, freetype, glew, hicolor-icon-theme, imath, libandroid-execinfo, libandroid-posix-semaphore, libblosc, libc++, libepoxy, libharu, libllvm, libpng, libpugixml, libraw, libsndfile, libspnav, libtbb, libtiff, libwebp, libx11, libxfixes, libxi, libxkbcommon, libyaml-cpp, oidn, openal-soft, opencolorio, openexr, openimageio, openjpeg, openpgl, openshadinglanguage, opensubdiv, openvdb, openxr, potrace, ptex, python, python-numpy, python-pip, shaderc, shared-mime-info, usd, zlib, zstd"
TERMUX_PKG_BUILD_DEPENDS="boost-headers, git-lfs, mold, sse2neon"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="requests"
# do not enable WITH_CYCLES_NATIVE_ONLY - results in crashing when opening the Edit->Preferences->System menu on some devices
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DPYTHON_LIBRARY=$TERMUX_PREFIX/lib/libpython$TERMUX_PYTHON_VERSION.so
-DPYTHON_INCLUDE_DIR=$TERMUX_PREFIX/include/python$TERMUX_PYTHON_VERSION
-DPYTHON_VERSION=$TERMUX_PYTHON_VERSION
-DPYTHON_SITE_PACKAGES=$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION/site-packages
-DPYTHON_EXECUTABLE=$TERMUX_PREFIX/bin/python$TERMUX_PYTHON_VERSION
-DWITH_PYTHON_INSTALL=OFF
-DWITH_CYCLES_NATIVE_ONLY=OFF
-DWITH_INSTALL_PORTABLE=OFF
-DWITH_GHOST_WAYLAND=OFF
-DWITH_PIPEWIRE=OFF
-DWITH_JACK=OFF
-DWITH_LINKER_MOLD=ON
-DWITH_MATERIALX=ON
-DCMAKE_PREFIX_PATH=$TERMUX_PREFIX/opt/ffmpeg7
"
TERMUX_PKG_RM_AFTER_INSTALL="
lib/python*
"

# tls: failed to verify certificate: x509: certificate signed by unknown authority
# this problem happens a lot in termux-docker and I don't know how to fix it
export GIT_SSL_NO_VERIFY=1

termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
	# ld.lld: error: undefined symbol: backtrace
	LDFLAGS+=" -landroid-execinfo"
	# ld.lld: error: version script assignment
	LDFLAGS+=" -Wl,--undefined-version"
	# error: undefined symbol: llvm::Triple::getEnvironmentVersionString() const
	LDFLAGS+=" -lLLVM -lclang-cpp"

	LDFLAGS+=" -Wl,-rpath=$TERMUX_PREFIX/opt/ffmpeg7/lib"

	# Fetch addons
	local _ARCH
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		_ARCH="arm64"
	else
		_ARCH=$TERMUX_ARCH
	fi
	python3 ./build_files/utils/make_update.py --architecture $_ARCH

	# enable temporarily if debugging
	#if [[ "$TERMUX_DEBUG_BUILD" == "true" ]]; then
	#	local dir="include/oneapi/tbb"
	#	find "$TERMUX_PREFIX/$dir" -type f | \
	#		xargs -n 1 sed -i \
	#		-e 's| _DEBUG| _DEBUG_DISABLING_THIS_TEMPORARILY|g'
	#	TERMUX_PKG_RM_AFTER_INSTALL+=" $dir"
	#fi
}

termux_step_post_make_install() {
	# Precompile and package .pyc files, like Arch Linux
	# avoids 'dpkg: warning: while removing blender, directory... not empty so not removed' while uninstalling
	python3 -m compileall "${TERMUX_PREFIX}/share/blender/3.6"
	python3 -O -m compileall "${TERMUX_PREFIX}/share/blender/3.6"
}
