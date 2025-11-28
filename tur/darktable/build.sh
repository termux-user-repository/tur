TERMUX_PKG_HOMEPAGE=https://www.darktable.org/
TERMUX_PKG_DESCRIPTION="Virtual lighttable and darkroom for photographers"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="5.2.1"
TERMUX_PKG_SRCURL=https://github.com/darktable-org/darktable/releases/download/release-${TERMUX_PKG_VERSION}/darktable-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=02f1aa9ae93949e7bc54c34eeb5ff92c2b87f95d2547865df55c60467564ee11
TERMUX_PKG_DEPENDS="exiv2, gdk-pixbuf, glib, graphicsmagick, gtk3, imath, json-glib, lensfun, libandroid-glob, libc++, libcairo, libcurl, libheif, libicu, libjpeg-turbo, libjxl, libllvm, liblua54, libpng, libpugixml, librsvg, libsqlite, libtiff, libwebp, libxml2, littlecms, ltrace, openexr, openjpeg, pango, portmidi, zlib"
TERMUX_PKG_BUILD_DEPENDS="libllvm-static"
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_REGEXP="\d+\.\d+\.\d+"
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBINARY_PACKAGE_BUILD=ON
-DUSE_OPENCL=OFF
-DUSE_OPENMP=OFF
"

termux_pkg_auto_update() {
	local tag="$(termux_github_api_get_tag "${TERMUX_PKG_SRCURL}" "${TERMUX_PKG_UPDATE_TAG_TYPE}")"
	if grep -qP "^release-${TERMUX_PKG_UPDATE_VERSION_REGEXP}\$" <<<"$tag"; then
		termux_pkg_upgrade_version "$tag"
	else
		echo "WARNING: Skipping auto-update: Not stable release($tag)"
	fi
}

termux_step_pre_configure() {
	LDFLAGS+=" -Wl,-rpath=$TERMUX_PREFIX/lib/darktable"

	LDFLAGS+=" -landroid-glob"
}
