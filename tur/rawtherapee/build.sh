TERMUX_PKG_HOMEPAGE=https://www.rawtherapee.com/
TERMUX_PKG_DESCRIPTION="raw image converter and digital photo processor"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="5.11"
TERMUX_PKG_SRCURL=https://github.com/Beep6581/RawTherapee/releases/download/${TERMUX_PKG_VERSION}/rawtherapee-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=e584c18dec112de29954b2b6471449a302a85e5cca4e42ede75fa333a36de724
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
