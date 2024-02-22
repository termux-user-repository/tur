TERMUX_PKG_HOMEPAGE=https://www.atnf.csiro.au/people/Mark.Calabretta/WCS/
TERMUX_PKG_DESCRIPTION="a C library that implements the 'World Coordinate System' (WCS) standard in FITS"
TERMUX_PKG_LICENSE="GPL-3.0, LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="8.2.2"
TERMUX_PKG_SRCURL=http://www.atnf.csiro.au/people/mcalabre/WCS/wcslib-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=6298220ae817f4e5522643ac4c3da2623be70a3484b1a4f37060bee3e4bd7833
TERMUX_PKG_DEPENDS="cfitsio"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-cfitsioinc=${TERMUX_PREFIX}/include
--with-cfitsiolib=${TERMUX_PREFIX}/lib
"

termux_step_pre_configure() {
	autoreconf -vfi
}
