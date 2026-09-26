TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps/Mahjogg"
TERMUX_PKG_DESCRIPTION="GNOME Mahjongg game"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION="51.1"
TERMUX_PKG_SRCURL="https://download.gnome.org/sources/gnome-mahjongg/${TERMUX_PKG_VERSION%%.*}/gnome-mahjongg-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=2ef9a1cd246d8ccc9ccd27fa435f972a81def9cf3eccc4c880cbb8929ffb8821
TERMUX_PKG_DEPENDS="glib, gtk4, libadwaita, libcairo, librsvg, opengl"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext, itstool"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_gir
	termux_setup_glib_cross_pkg_config_wrapper
}
