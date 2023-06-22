TERMUX_PKG_HOMEPAGE=https://github.com/PyWavelets/pywt
TERMUX_PKG_DESCRIPTION="Wavelet Transforms in Python"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.4.1"
TERMUX_PKG_SRCURL=https://github.com/PyWavelets/pywt/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=b1d0edca28998d35ec1bbc31f009b334a98b475f67b1c84f7521eb689a8607f8
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
	LDFLAGS+=" -Wl,--no-as-needed -lpython${TERMUX_PYTHON_VERSION}"
}

termux_step_configure() {
	:
}

termux_step_make_install() {
    pip install wheel cython
	pip install --no-build-isolation --no-deps . --prefix $TERMUX_PREFIX -vvv
}
