TERMUX_PKG_HOMEPAGE=https://astrometry.net/
TERMUX_PKG_DESCRIPTION="automatic recognition of astronomical images"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.97"
TERMUX_PKG_SRCURL=https://github.com/dstndstn/astrometry.net/releases/download/${TERMUX_PKG_VERSION}/astrometry.net-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=e4eef1b658ba5ad462282b661c0ca3a5c538ba1716e853f7970b7b9fa4a33459
TERMUX_PKG_DEPENDS="cfitsio, curl, file, libandroid-glob, libbz2, libcairo, libjpeg-turbo, libpng, netpbm, python, python-numpy, python-fitsio, swig, wcslib, zlib"
TERMUX_PKG_SUGGESTS="astrometry.net-data-basic"
_NUMPY_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python-numpy/build.sh; echo $TERMUX_PKG_VERSION)
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel, setuptools, 'numpy==$_NUMPY_VERSION'"
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
