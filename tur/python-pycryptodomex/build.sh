TERMUX_PKG_HOMEPAGE=https://www.pycryptodome.org/
TERMUX_PKG_DESCRIPTION="A self-contained Python package of low-level cryptographic primitives"
TERMUX_PKG_LICENSE="BSD 2-Clause, Public Domain"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="3.19.1"
TERMUX_PKG_SRCURL="https://github.com/Legrandin/pycryptodome/archive/refs/tags/v${TERMUX_PKG_VERSION}x.tar.gz"
TERMUX_PKG_SHA256=9eb984da872c8df2ad0e925f8bb25487f2fdb362f46a414191daac076a8f26ca
TERMUX_PKG_DEPENDS="python, python-pip"
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel, 'setuptools==67.8.0'"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	LDFLAGS+=" -Wl,--no-as-needed -lpython${TERMUX_PYTHON_VERSION}"
}

termux_step_make() {
	:
}

termux_step_make_install() {
	pip install . --prefix=$TERMUX_PREFIX -vv --no-build-isolation --no-deps	
}
