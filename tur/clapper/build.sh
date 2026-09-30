TERMUX_PKG_HOMEPAGE="https://github.com/Rafostar/clapper"
TERMUX_PKG_DESCRIPTION="A modern media player powered by GStreamer and built for the GNOME desktop environment."
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.10.0"
TERMUX_PKG_SRCURL="https://github.com/Rafostar/clapper/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="344c0f20e540a63c6fb44cdd5de88c168ed145bb66c1307e79b2b08124780118"
TERMUX_PKG_DEPENDS="gtk4, glib, gobject-introspection, gstreamer, gst-plugins-base, gst-plugins-good, gst-plugins-bad, gst-plugins-ugly, gst-libav, libadwaita, libsoup3, libmicrodns, libpeas2"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, glib-cross, valac"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_VERSIONED_GIR=false
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dintrospection=enabled
-Dvapi=enabled
-Denhancers-loader=enabled
-Dmpris=disabled
-Dserver=disabled
-Dpipeline-preview=disabled
"

termux_step_pre_configure() {
	termux_setup_gir
	termux_setup_glib_cross_pkg_config_wrapper
	export PATH="${TERMUX_PREFIX}/opt/glib/cross/bin:$PATH"
	sed -i 's/update_mime_database: not is_windows/update_mime_database: false/g' src/bin/clapper-app/data/meson.build
}
