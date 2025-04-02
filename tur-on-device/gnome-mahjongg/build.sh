TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps/Mahjogg"
TERMUX_PKG_DESCRIPTION="GNOME Mahjongg game"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION=48.0
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/gnome-mahjongg/${TERMUX_PKG_VERSION%.*}/gnome-mahjongg-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=aeb16f4c940bdb6a670c7d9acdd50dd0ec20b321bd7075a985891fbbebcd4fed
TERMUX_PKG_DEPENDS="glib, gtk4, libadwaita, libcairo, librsvg, opengl"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext, itstool"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	export PYTHONDONTWRITEBYTECODE=1
	termux_setup_gir
}
