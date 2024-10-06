TERMUX_PKG_HOMEPAGE=https://cairographics.org/pycairo
TERMUX_PKG_DESCRIPTION="This package contains modules that allow you to use the Cairo vector graphics library in Python3 programs."
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION="1.26.1"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/pygobject/pycairo/releases/download/v${TERMUX_PKG_VERSION}/pycairo-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=a11b999ce55b798dbf13516ab038e0ce8b6ec299b208d7c4e767a6f7e68e8430
TERMUX_PKG_DEPENDS="python, libcairo"
TERMUX_PKG_PYTHON_BUILD_DEPS="wheel"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	LDFLAGS+=" -lpython${TERMUX_PYTHON_VERSION}"
	rm -f meson.build
}
