TERMUX_PKG_HOMEPAGE="https://gitlab.gnome.org/GNOME/evolution/-/wikis/home"
TERMUX_PKG_DESCRIPTION="The Evolution Data Server package provides a unified backend for programs that work with contacts, tasks, and calendar information."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=3.56.0
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/evolution-data-server/${TERMUX_PKG_VERSION%.*}/evolution-data-server-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=7ae5482aa4ee2894467716c5be982500e1d511dddf4ab29b68fdb107d7f8a8ff
TERMUX_PKG_DEPENDS="libcairo, glib, gtk4, krb5, libical, libsoup3, libuuid, libxml2, libnspr, libnss, openldap, libsqlite, webkit2gtk-4.1, webkitgtk-6.0"
TERMUX_PKG_BUILD_DEPENDS="perl, intltool, python"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure(){
	cpan -fi XML::Parser
	autoreconf -vf
}

termux_step_make(){
	make -j $TERMUX_PKG_MAKE_PROCESSES
}

termux_step_make_install(){
	make install
}
