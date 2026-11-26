TERMUX_PKG_HOMEPAGE="https://www.enlightenment.org"
TERMUX_PKG_DESCRIPTION="The Enlightenment Window Manager"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.28.0
TERMUX_PKG_SRCURL="https://download.enlightenment.org/rel/apps/enlightenment/enlightenment-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=8ab2d8a76c4009d142561f5136048b969796f4a79df8af6018713d1d163a5c6b
TERMUX_PKG_DEPENDS="bc, dbus, efl, libandroid-shmem, libexif, libx11, libxcomposite, libxcursor, libxdamage, libxext, libxinerama, libxkbcommon, libxrandr, libxtst, pulseaudio"
TERMUX_PKG_MESON_NATIVE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dpam=false
-Delput=false
-Dgesture-recognition=false
-Ddevice-udev=false
-Dsystemd=false
-Dmount-udisks=false
-Dmount-eeze=false
-Dbluez5=false
-Dconnman=false
-Dnetworkmanager=false
-Dpackagekit=false
-Dinstall-sysactions=false
-Dinstall-system=false
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
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
