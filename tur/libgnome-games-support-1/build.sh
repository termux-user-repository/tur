TERMUX_PKG_HOMEPAGE="https://gitlab.gnome.org/GNOME/libgnome-games-support/"
TERMUX_PKG_DESCRIPTION="Support library for GNOME games"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION=1.8.2
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/libgnome-games-support/${TERMUX_PKG_VERSION%.*}/libgnome-games-support-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=28434604a7b038731ac0231731388ff104f565bb2330cc24e78cda04cfd3ef7d
TERMUX_PKG_DEPENDS="glib, gtk4, libgee"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext"

termux_step_pre_configure() {
	termux_setup_gir
}
