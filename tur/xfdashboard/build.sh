TERMUX_PKG_HOMEPAGE=https://gitlab.xfce.org/apps/xfdashboard
TERMUX_PKG_DESCRIPTION="Maybe a Gnome shell like dashboard for Xfce"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SRCURL="https://archive.xfce.org/src/apps/xfdashboard/${TERMUX_PKG_VERSION:0:3}/xfdashboard-$TERMUX_PKG_VERSION.tar.bz2"
TERMUX_PKG_SHA256=a5284343e5ce09722f98d3b578588b36923e1ae5649754aa906980fdcdef48a5
TERMUX_PKG_DEPENDS="clutter, garcon, libwnck"
TERMUX_PKG_BUILD_DEPENDS="glib-cross"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	local _WRAPPER_BIN="${TERMUX_PKG_BUILDDIR}/_wrapper/bin"
	mkdir -p "${_WRAPPER_BIN}"
	if [[ "${TERMUX_ON_DEVICE_BUILD}" == "false" ]]; then
		sed "s|^export PKG_CONFIG_LIBDIR=|export PKG_CONFIG_LIBDIR=${TERMUX_PREFIX}/opt/glib/cross/lib/x86_64-linux-gnu/pkgconfig:|" \
			"${TERMUX_STANDALONE_TOOLCHAIN}/bin/pkg-config" \
			> "${_WRAPPER_BIN}/pkg-config"
		chmod +x "${_WRAPPER_BIN}/pkg-config"
		export PKG_CONFIG="${_WRAPPER_BIN}/pkg-config"
	fi
	export PATH="${_WRAPPER_BIN}:${PATH}"
}
