TERMUX_PKG_HOMEPAGE=https://github.com/PyWavelets/pywt
TERMUX_PKG_DESCRIPTION="Wavelet Transforms in Python"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.5.0"
TERMUX_PKG_SRCURL=https://github.com/PyWavelets/pywt/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=5aedfa9bd629f104a04fda88b92582bda38ab22282ce5048b5760b5d18e83fc9
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, python-numpy"
TERMUX_PKG_BUILD_DEPENDS="python-pip"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_RM_AFTER_INSTALL="
lib/python${TERMUX_PYTHON_VERSION}/__pycache__
lib/python${TERMUX_PYTHON_VERSION}/site-packages/pip
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	LDFLAGS+=" -Wl,--no-as-needed -lpython${TERMUX_PYTHON_VERSION}"
}

termux_step_configure() {
	:
}

termux_step_make_install() {
	pip install wheel cython meson-python
	pip install --no-build-isolation --no-deps . --prefix $TERMUX_PREFIX -vvv
}
