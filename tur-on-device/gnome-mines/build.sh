TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps/Mines"
TERMUX_PKG_DESCRIPTION="GNOME Mines Sweeper game"
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION=48.1
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/gnome-mines/${TERMUX_PKG_VERSION%.*}/gnome-mines-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=ef4b2d2dde3bec614157edde4d9189cc6afe692952a2dd55b2870e2e62ed8104
TERMUX_PKG_DEPENDS="glib, gtk4, libadwaita, libcairo, librsvg, libgnome-games-support"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext, itstool"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	export PYTHONDONTWRITEBYTECODE=1
	termux_setup_gir
}
