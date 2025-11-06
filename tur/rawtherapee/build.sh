TERMUX_PKG_HOMEPAGE=https://www.rawtherapee.com/
TERMUX_PKG_DESCRIPTION="raw image converter and digital photo processor"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="5.12"
TERMUX_PKG_SRCURL=https://github.com/Beep6581/RawTherapee/releases/download/${TERMUX_PKG_VERSION}/rawtherapee-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=d9a6c10537d64a285bc465675fe59aaa94ce3223823dfbecf0ae2c9599082d57
TERMUX_PKG_DEPENDS="exiv2, fftw, glib, gtk3, gtkmm3, lensfun, libcanberra, libexpat, libglibmm-2.4, libiptcdata, libjpeg-turbo, libpng, libraw, librsvg, libsigc++-2.0, libtiff, littlecms, zlib"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_REGEXP="\d+\.\d+"
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBINARY_PACKAGE_BUILD=ON
-DWITH_SYSTEM_LIBRAW=TRUE
"

termux_step_pre_configure() {
	LDFLAGS+=" -fopenmp -static-openmp"
}
