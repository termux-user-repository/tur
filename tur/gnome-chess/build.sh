TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps(2f)Chess.html"
TERMUX_PKG_DESCRIPTION="GNOME Chess game"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION="50.1"
TERMUX_PKG_SRCURL="https://download.gnome.org/sources/gnome-chess/${TERMUX_PKG_VERSION%.*}/gnome-chess-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=dc29a330b8157cfac8d04a24c1afa848b6f0f4792454d8479d2bfeb7a3519298
TERMUX_PKG_DEPENDS="glib, gtk4, gnuchess, libadwaita, libcairo, librsvg, opengl, pango"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext, itstool"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_gir
	termux_setup_glib_cross_pkg_config_wrapper
}
