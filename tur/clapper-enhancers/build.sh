TERMUX_PKG_HOMEPAGE="https://github.com/Rafostar/clapper-enhancers"
TERMUX_PKG_DESCRIPTION="Plugins enhancing Clapper library capabilities (yt-dlp, PeerTube, etc.)"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.10.0"
TERMUX_PKG_SRCURL="https://github.com/Rafostar/clapper-enhancers/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=54061d27e32b4529dba62f7dc81c72405388ad09a5b3d8d6860d69c7206bfd97
TERMUX_PKG_DEPENDS="clapper, glib, libpeas2, gstreamer, gst-plugins-base, libmicrodns, python, pygobject, libsqlite, libsoup3, python-yt-dlp, json-glib"
TERMUX_PKG_BUILD_DEPENDS="glib-cross"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dcontrol-hub=disabled
-Dlbry=disabled
-Dmedia-scanner=disabled
-Dmpris=disabled
-Dparser-m3u=enabled
-Dpeertube=enabled
-Drecall=disabled
-Dyt-dlp=enabled
"

termux_step_pre_configure() {
	termux_setup_glib_cross_pkg_config_wrapper
}
