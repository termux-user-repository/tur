TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps(2f)Chess.html"
TERMUX_PKG_DESCRIPTION="GNOME Chess game"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION=49.2
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/gnome-chess/${TERMUX_PKG_VERSION%.*}/gnome-chess-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=c40a0004a473fe749ac2fa4fad98db64118d18f9fd9ac02eecfa364f03dbe9b0
TERMUX_PKG_DEPENDS="glib, gtk4, gnuchess, libadwaita, libcairo, librsvg, opengl, pango"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext, itstool"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	export PYTHONDONTWRITEBYTECODE=1
	termux_setup_gir
}
