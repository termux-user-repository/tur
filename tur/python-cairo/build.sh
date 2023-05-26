TERMUX_PKG_HOMEPAGE=https://cairographics.org/pycairo
TERMUX_PKG_DESCRIPTION="This package contains modules that allow you to use the Cairo vector graphics library in Python3 programs."
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION="1.23.0"
TERMUX_PKG_SRCURL=https://github.com/pygobject/pycairo/releases/download/v${TERMUX_PKG_VERSION}/pycairo-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=9b61ac818723adc04367301317eb2e814a83522f07bbd1f409af0dada463c44c
TERMUX_PKG_DEPENDS="python, libcairo"
TERMUX_PKG_PYTHON_BUILD_DEPS="wheel"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	LDFLAGS+=" -lpython${TERMUX_PYTHON_VERSION}"
	rm -f meson.build
}
