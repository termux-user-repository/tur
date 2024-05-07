TERMUX_PKG_HOMEPAGE=https://astrometry.net/
TERMUX_PKG_DESCRIPTION="automatic recognition of astronomical images"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.95"
TERMUX_PKG_SRCURL=https://github.com/dstndstn/astrometry.net/releases/download/${TERMUX_PKG_VERSION}/astrometry.net-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=b8239e39b44d6877b0427edeffd95efc258520044ff5afdd0fb1a89ff8f1afc0
TERMUX_PKG_DEPENDS="cfitsio, curl, file, libandroid-glob, libbz2, libcairo, libjpeg-turbo, libpng, netpbm, python, python-numpy, python-fitsio, swig, wcslib, zlib"
TERMUX_PKG_SUGGESTS="astrometry.net-data-basic"
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel, setuptools, numpy"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BLACKLISTED_ARCHES="arm" # FIXME: arm cross-compile C compiler fails for unknown reason

termux_step_make () {
	make TERMUX_HOST_PLATFORM="$TERMUX_HOST_PLATFORM"
	make py CAIRO_INC=-I"$TERMUX_PREFIX"/include/cairo
	make extra CAIRO_INC=-I"$TERMUX_PREFIX"/include/cairo
}

termux_step_make_install () {
	make install INSTALL_DIR="$TERMUX_PREFIX" CAIRO_INC=-I"$TERMUX_PREFIX"/include/cairo
}
