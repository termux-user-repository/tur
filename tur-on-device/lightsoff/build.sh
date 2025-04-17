TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps/Lightsoff"
TERMUX_PKG_DESCRIPTION="GNOME Lightsoff game"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION=48.1
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/lightsoff/${TERMUX_PKG_VERSION%.*}/lightsoff-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=2ec99501713dbcd13c5a565a2e118cc4cc2b502836b387a7736cfba40a8b3989
TERMUX_PKG_DEPENDS="glib, gtk4, libadwaita, libcairo, librsvg, libgnome-games-support, pango"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext, itstool"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	export PYTHONDONTWRITEBYTECODE=1
	termux_setup_gir
}
