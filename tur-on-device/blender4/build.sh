TERMUX_PKG_HOMEPAGE=https://www.blender.org
TERMUX_PKG_DESCRIPTION="A fully integrated 3D graphics creation suite"
# Blender website recommends distributing binaries under "GPL-3.0-or-later" license
# https://www.blender.org/about/license/
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="4.5.5"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://projects.blender.org/blender/blender
# Blender does not support 32-bit
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_DEPENDS="alembic, boost, brotli, desktop-file-utils, draco, ffmpeg, fftw, freetype, glew, hicolor-icon-theme, imath, libandroid-execinfo, libandroid-posix-semaphore, libblosc, libc++, libepoxy, libharu, libpng, libpugixml, libraw, libsndfile, libspnav, libtbb, libtiff, libwebp, libx11, libxfixes, libxi, libxkbcommon, libyaml-cpp, oidn, openal-soft, opencolorio, openexr, openimageio, openjpeg, openpgl, openshadinglanguage, opensubdiv, openvdb, openxr, potrace, ptex, python, python-numpy, python-pip, shaderc, shared-mime-info, usd, zlib, zstd"
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
"
TERMUX_PKG_RM_AFTER_INSTALL="
lib/python*
"

# tls: failed to verify certificate: x509: certificate signed by unknown authority
# this problem happens a lot in termux-docker and I don't know how to fix it
export GIT_SSL_NO_VERIFY=1

# fetch full repository properly, like Arch Linux
# https://gitlab.archlinux.org/archlinux/packaging/packages/blender/-/blob/6ed136d712fdaff25d14a46d01cd66d377cca47b/PKGBUILD
termux_step_get_source() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	local TMP_CHECKOUT=$TERMUX_PKG_CACHEDIR/tmp-checkout
	local TMP_CHECKOUT_VERSION=$TERMUX_PKG_CACHEDIR/tmp-checkout-version
	if [ ! -f $TMP_CHECKOUT_VERSION ] || [ "$(cat $TMP_CHECKOUT_VERSION)" != "$TERMUX_PKG_VERSION" ]; then
		rm -rf $TMP_CHECKOUT
		git clone --depth 1 \
			--branch "v${TERMUX_PKG_VERSION#*:}" \
			"${TERMUX_PKG_SRCURL:4}" \
			$TMP_CHECKOUT
		pushd "$TMP_CHECKOUT"
		# fetch assets from git-lfs like Arch Linux
		git lfs install --local
		git remote add network-origin "${TERMUX_PKG_SRCURL:4}"
		git lfs fetch network-origin
		git lfs checkout
		popd
		echo "$TERMUX_PKG_VERSION" > $TMP_CHECKOUT_VERSION
	fi
	rm -rf $TERMUX_PKG_SRCDIR
	cp -Rf $TMP_CHECKOUT $TERMUX_PKG_SRCDIR
}

termux_step_pre_configure() {
	# ld.lld: error: undefined symbol: backtrace
	LDFLAGS+=" -landroid-execinfo"
	# ld.lld: error: undefined symbol: libandroid_sem_open
	LDFLAGS+=" -landroid-posix-semaphore"
	# ld.lld: error: version script assignment
	LDFLAGS+=" -Wl,--undefined-version"

	# Making blender4 not conflict with the other blender package (blender 3)
	# inspired by Gentoo, which has a blender that can have multiple versions
	# installed in the same Gentoo simultaneously in a way that works very well.
	# https://github.com/gentoo/gentoo/blob/89bae30fab90f218bd7a1d56e825819e4576a4c4/media-gfx/blender/blender-4.4.3.ebuild#L312
	# This is a bit different from how Gentoo does it - rewritten,
	# and adapted to Termux by keeping non-versioned files out of $TERMUX_PREFIX during termux_step_make_install()
	BV="${TERMUX_PKG_VERSION%.*}"
	BV="${BV#*:}"
	sed \
		-e "s|blender-thumbnailer|blender-${BV}-thumbnailer|g" \
		-i source/blender/blendthumb/CMakeLists.txt
	sed \
		-e "s|(blender|(blender-${BV}|g" \
		-e "s|TARGET blender|TARGET blender-${BV}|g" \
		-e "s|TARGETS blender|TARGETS blender-${BV}|g" \
		-e "s|    blender|    blender-${BV}|g" \
		-e "s|bin/blender|bin/blender-${BV}|g" \
		-e "s|share/doc/blender|share/doc/blender-${BV}|g" \
		-e "s|blender.svg|blender-${BV}.svg|g" \
		-e "s|blender-symbolic.svg|blender-${BV}-symbolic.svg|g" \
		-e "s|blender.desktop|blender-${BV}.desktop|g" \
		-e "s|org.blender.Blender.metainfo.xml|blender-${BV}.metainfo.xml|g" \
		-i source/creator/CMakeLists.txt
	sed \
		-e "s|TARGET_FILE_DIR:blender|TARGET_FILE_DIR:blender-${BV}|g" \
		-i tests/python/CMakeLists.txt
	sed \
		-e "s|Name=Blender|Name=Blender ${BV}|g" \
		-e "s|Exec=blender|Exec=blender-${BV}|g" \
		-e "s|Icon=blender|Icon=blender-${BV}|g" \
		-i release/freedesktop/blender.desktop
	mv \
		"release/freedesktop/icons/scalable/apps/blender.svg" \
		"release/freedesktop/icons/scalable/apps/blender-${BV}.svg"
	mv \
		"release/freedesktop/icons/symbolic/apps/blender-symbolic.svg" \
		"release/freedesktop/icons/symbolic/apps/blender-${BV}-symbolic.svg"
	mv \
		"release/freedesktop/blender.desktop" \
		"release/freedesktop/blender-${BV}.desktop"
	mv \
		"release/freedesktop/org.blender.Blender.metainfo.xml" \
		"release/freedesktop/blender-${BV}.metainfo.xml"

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
	# avoids 'dpkg: warning: while removing blender4, directory... not empty so not removed' while uninstalling
	python3 -m compileall "${TERMUX_PREFIX}/share/blender/${BV}"
	python3 -O -m compileall "${TERMUX_PREFIX}/share/blender/${BV}"
}
