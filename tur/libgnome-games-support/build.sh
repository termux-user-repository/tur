TERMUX_PKG_HOMEPAGE="https://gitlab.gnome.org/GNOME/libgnome-games-support/"
TERMUX_PKG_DESCRIPTION="Support library for GNOME games"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION=2.0.1
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/libgnome-games-support/${TERMUX_PKG_VERSION%.*}/libgnome-games-support-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=0186f25c4892c86c7eac43a307fc19db696df4f19aca7f54e83c221df9d9790a
TERMUX_PKG_DEPENDS="glib, gtk4, libgee"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext, attr"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_gir
}
