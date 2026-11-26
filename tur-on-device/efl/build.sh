TERMUX_PKG_HOMEPAGE=https://www.enlightenment.org
TERMUX_PKG_DESCRIPTION="The Enlightenment Foundation Libraries (EFL)"
TERMUX_PKG_LICENSE="BSD 2-Clause, LGPL-2.1, GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.29.0
TERMUX_PKG_SRCURL="https://download.enlightenment.org/rel/libs/efl/efl-$TERMUX_PKG_VERSION.tar.xz"
TERMUX_PKG_SHA256=248bc76141f2b8b006ccba9e0bb2cb46cbcb1be4181a1cf2728187f778853654
TERMUX_PKG_DEPENDS="dbus, fribidi, giflib, gst-plugins-base, gstreamer, harfbuzz, libandroid-execinfo, libandroid-shmem, libjpeg-turbo, libraw, librsvg, libsndfile, libspectre, libtiff, libwayland, libwayland-protocols, libwebp, libxcomposite, libxcursor, libxdamage, libxi, libxinerama, libxkbcommon, libxrandr, libxtst, lua52, luajit, openjpeg, poppler, pulseaudio"
TERMUX_PKG_BUILD_DEPENDS="bison"
TERMUX_PKG_MESON_NATIVE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Deeze=false
-Dsystemd=false
-Dinput=false
-Dwl=true
-Dpipewire=false
-Dbuild-tests=false
-Dbuild-examples=false
-Decore-imf-loaders-disabler=['ibus','scim']
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	if [[ "$TERMUX_ARCH" = arm ]] ; then
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -Dnative-arch-optimization=false"
	fi

	LDFLAGS+=" -landroid-shmem"
}

termux_step_configure_meson() {
	termux_setup_meson
	sed -i '/needs_exe_wrapper/d' "$TERMUX_MESON_CROSSFILE"

	local _meson_buildtype="release"
	local _meson_stripflag="--strip"
	if [ "$TERMUX_DEBUG_BUILD" = "true" ]; then
		_meson_buildtype="debug"
		_meson_stripflag=
	fi

	CC=gcc CXX=g++ CFLAGS= CXXFLAGS= CPPFLAGS= LDFLAGS= $TERMUX_MESON \
		setup \
		$TERMUX_PKG_SRCDIR \
		$TERMUX_PKG_BUILDDIR \
		--$(test "${TERMUX_PKG_MESON_NATIVE}" = "true" && echo "native-file" || echo "cross-file") $TERMUX_MESON_CROSSFILE \
		--prefix $TERMUX_PREFIX \
		--libdir $TERMUX__PREFIX__LIB_SUBDIR \
		--includedir $TERMUX__PREFIX__INCLUDE_SUBDIR \
		--buildtype ${_meson_buildtype} \
		${_meson_stripflag} \
		$TERMUX_PKG_EXTRA_CONFIGURE_ARGS \
		|| (termux_step_configure_meson_failure_hook && false)
}

termux_step_post_make_install() {
	# Remove host/build artifacts that might conflict
	find "$TERMUX_PREFIX/lib" -name "*.pyc" -delete || true
}
