TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps/Swell%20Foop"
TERMUX_PKG_DESCRIPTION="GNOME colored tiles puzzle game"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION=48.1
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/swell-foop/${TERMUX_PKG_VERSION%.*}/swell-foop-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=5b9630878fe701aee751ed46ff765c2bcd9f815a4e5582676a3c26b31182031b
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
