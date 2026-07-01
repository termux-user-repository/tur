TERMUX_PKG_HOMEPAGE=https://github.com/esheldon/fitsio
TERMUX_PKG_DESCRIPTION="A python package for FITS input/output wrapping cfitsio"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.4.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL="https://github.com/esheldon/fitsio/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=7ece7c8234058b5a2c97f7b1259ff396f2d1e91e1cb263ceebd16dde63ab1b9f
TERMUX_PKG_DEPENDS="cfitsio, python, python-pip, python-numpy"
_NUMPY_VERSION=$(. "$TERMUX_SCRIPTDIR/packages/python-numpy/build.sh"; echo "$TERMUX_PKG_VERSION")
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="wheel, 'numpy==$_NUMPY_VERSION'"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	export FITSIO_USE_SYSTEM_FITSIO=1
}

termux_step_make_install() {
	# use --no-build-isolation to ensure the correct numpy installation is detected
	pip install --no-deps --no-build-isolation . --prefix "$TERMUX_PREFIX"
}
