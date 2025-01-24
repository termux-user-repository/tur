TERMUX_PKG_HOMEPAGE=https://github.com/esheldon/fitsio
TERMUX_PKG_DESCRIPTION="A python package for FITS input/output wrapping cfitsio"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.2.5"
TERMUX_PKG_SRCURL=https://github.com/esheldon/fitsio/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=037d6fc4573c89f5da76ddeb106a1f43c02d6f7fe466e483287c2e5691c5338a
TERMUX_PKG_DEPENDS="cfitsio, python, python-numpy"
_NUMPY_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python-numpy/build.sh; echo $TERMUX_PKG_VERSION)
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel, 'numpy==$_NUMPY_VERSION'"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
	fi
	export FITSIO_USE_SYSTEM_FITSIO=1
}
