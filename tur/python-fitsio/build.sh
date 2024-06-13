TERMUX_PKG_HOMEPAGE=https://github.com/esheldon/fitsio
TERMUX_PKG_DESCRIPTION="A python package for FITS input/output wrapping cfitsio"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.2.3"
TERMUX_PKG_SRCURL=https://github.com/esheldon/fitsio/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=2b6d219674bb720dd25a793fd5be281b44a742d03a23d60803bac92e406a9afd
TERMUX_PKG_DEPENDS="cfitsio, python, python-numpy"
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel, numpy"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
	fi
	export FITSIO_USE_SYSTEM_FITSIO=1
}
