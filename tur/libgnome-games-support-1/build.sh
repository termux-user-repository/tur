TERMUX_PKG_HOMEPAGE="https://gitlab.gnome.org/GNOME/libgnome-games-support/"
TERMUX_PKG_DESCRIPTION="Support library for GNOME games"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION=1.8.2
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/libgnome-games-support/${TERMUX_PKG_VERSION%.*}/libgnome-games-support-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=cb6c4859d16bffc941b1098f7f624c84e6a3339fce45629e45ba8b3f653d58f9
TERMUX_PKG_DEPENDS="glib, gtk4, libgee"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext"

termux_step_pre_configure() {
	termux_setup_gir
}
