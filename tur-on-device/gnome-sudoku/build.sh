TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps(2f)Sudoku.html"
TERMUX_PKG_DESCRIPTION="GNOME Sudoku game"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=49.0
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/gnome-sudoku/${TERMUX_PKG_VERSION%.*}/gnome-sudoku-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=0b37cde207922c9a4a8a2215e2cdfe9f32f40161d28b6027f9a6913025b50ab5
TERMUX_PKG_DEPENDS="glib, gtk4, json-glib, libadwaita, libcairo, libgee, opengl, qqwing"
TERMUX_PKG_BUILD_DEPENDS="blueprint-compiler, itstool, g-ir-scanner, gettext"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	export PYTHONDONTWRITEBYTECODE=1
	termux_setup_gir
}
