TERMUX_PKG_HOMEPAGE=https://gitlab.freedesktop.org/pipewire/helvum
TERMUX_PKG_DESCRIPTION="A GTK patchbay for pipewire. "
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.0.1"
TERMUX_PKG_SRCURL=git+https://github.com/knyipab/helvum
TERMUX_PKG_GIT_BRANCH="main"
# TERMUX_PKG_VERSION="0.5.1"
# TERMUX_PKG_SRCURL="https://gitlab.freedesktop.org/pipewire/helvum/-/archive/${TERMUX_PKG_VERSION}/helvum-${TERMUX_PKG_VERSION}.tar.bz2"
# TERMUX_PKG_SHA256=d4f5cc0c3a70a91edfc816f12a10426dadd9ca74ea82662e2df5e6c4eb31d8ca
TERMUX_PKG_DEPENDS="gdk-pixbuf, glib, graphene, gtk4, hicolor-icon-theme, libadwaita, libcairo, pipewire, pango"
TERMUX_PKG_BUILD_DEPENDS="appstream-glib"
# TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

termux_step_configure() {
	termux_setup_meson
	termux_setup_rust

	TERMUX_MESON_CROSSFILE=$TERMUX_PKG_TMPDIR/meson-crossfile-$TERMUX_ARCH.txt
	sed -i "s/cmake = 'cmake'/cmake = 'cmake'\nrust = 'rustc'/" "$TERMUX_MESON_CROSSFILE"

	local _meson_buildtype="minsize"
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
		--libdir lib \
		--buildtype ${_meson_buildtype} \
		${_meson_stripflag} \
		$TERMUX_PKG_EXTRA_CONFIGURE_ARGS \
		|| (termux_step_configure_meson_failure_hook && false)
}
