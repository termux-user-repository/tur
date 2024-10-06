# This just serves as an automatic installer for seledroid-app,
# since the one in the PyPI can't do that

TERMUX_PKG_HOMEPAGE=https://github.com/luanon404/seledroid
TERMUX_PKG_DESCRIPTION="Python library to control android webdriver."
TERMUX_PKG_LICENSE="Unlicense"
TERMUX_PKG_MAINTAINER="@nacho00112"
TERMUX_PKG_VERSION=1.1.0
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://github.com/nacho00112/seledroid/archive/refs/heads/main.zip
TERMUX_PKG_SHA256=2cdd02af593a8d2a180288df9ad62c1d045ae3e5d5fed13ddfdc7e8a192a3892
TERMUX_PKG_DEPENDS="python, seledroid-app"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_SETUP_PYTHON=true

termux_step_make_install() {
	pip3 install . --prefix $TERMUX_PREFIX
}
