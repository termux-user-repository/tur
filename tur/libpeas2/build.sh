TERMUX_PKG_HOMEPAGE=https://wiki.gnome.org/Projects/Libpeas
TERMUX_PKG_DESCRIPTION="A GObject plugin framework (version 2)"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="2.2.1"
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/libpeas/${TERMUX_PKG_VERSION%.*}/libpeas-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=589eca89b437006edf3755478df037c740a2a84cfa5d202dbad6095e828e2488
TERMUX_PKG_DEPENDS="glib, gobject-introspection, python, pygobject"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, glib-cross"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DISABLE_GIR=false
TERMUX_PKG_VERSIONED_GIR=false
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dgjs=false
-Dlua51=false
-Dpython3=true
-Dintrospection=true
-Dvapi=true
-Dgtk_doc=false
"

termux_step_pre_configure() {
	termux_setup_gir
	termux_setup_glib_cross_pkg_config_wrapper

	export TERMUX_MESON_ENABLE_SOVERSION=1
}

termux_step_post_massage() {
	local _SOVERSION_GUARD_FILES=(
		'lib/libpeas-2.so.0'
	)

	local f
	for f in "${_SOVERSION_GUARD_FILES[@]}"; do
		[ -e "${f}" ] || termux_error_exit "SOVERSION guard check failed."
	done
}
