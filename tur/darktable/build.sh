TERMUX_PKG_HOMEPAGE=https://www.darktable.org/
TERMUX_PKG_DESCRIPTION="virtual lighttable and darkroom for photographers"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="4.6.0"
TERMUX_PKG_SRCURL=https://github.com/darktable-org/darktable/releases/download/release-${TERMUX_PKG_VERSION}/darktable-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=724b27e3204d1822de6dc53ea090a6b1ce55f7c32226d34642689775c68aacc2
TERMUX_PKG_DEPENDS="exiv2, glib, graphicsmagick, gtk3, imath, json-glib, lensfun, libheif, libjxl, libllvm, liblua54, libpugixml, libsqlite, littlecms, openexr, openjpeg, portmidi"
TERMUX_PKG_BUILD_DEPENDS="libllvm-static"
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBINARY_PACKAGE_BUILD=ON
"

termux_step_pre_configure() {
	_RPATH_FLAG="-Wl,-rpath=$TERMUX_PREFIX/lib"
	_RPATH_FLAG_ADD="-Wl,-rpath=$TERMUX_PREFIX/lib/darktable -Wl,-rpath=$TERMUX_PREFIX/lib"
	LDFLAGS="${LDFLAGS/$_RPATH_FLAG/$_RPATH_FLAG_ADD}"
}
