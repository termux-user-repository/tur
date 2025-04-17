TERMUX_PKG_HOMEPAGE="https://gitlab.gnome.org/GNOME/libgnome-games-support/"
TERMUX_PKG_DESCRIPTION="Support library for GNOME games"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION=2.0.1
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/libgnome-games-support/${TERMUX_PKG_VERSION%.*}/libgnome-games-support-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=17626f4a4039f13d033382119c7ab4e10fcf17e3817b309c8223bbbc2379377a
TERMUX_PKG_DEPENDS="glib, gtk4, libgee"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext, attr"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_gir
}
