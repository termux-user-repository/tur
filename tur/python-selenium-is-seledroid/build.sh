TERMUX_PKG_HOMEPAGE=https://github.com/nacho00112/tur
TERMUX_PKG_DESCRIPTION="A browser automation framework and ecosystem. This dummy selenium uses seledroid as his backend."
TERMUX_PKG_SKIP_SRC_EXTRACT=true
# seledroid is unlicensed, the original selenium is Apache-2.0
TERMUX_PKG_LICENSE="Unlicense"
TERMUX_PKG_MAINTAINER="@nacho00112"
TERMUX_PKG_VERSION=4.10.0
TERMUX_PKG_REVISION=1
TERMUX_PKG_DEPENDS="python, python-seledroid"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_get_source() {
	mkdir -p $TERMUX_PKG_SRCDIR
	cp $TERMUX_PKG_BUILDER_DIR/{setup.py,selenium.py} $TERMUX_PKG_SRCDIR/
}

termux_step_make_install() {
	export SELENIUM_PKG_VERSION="$TERMUX_PKG_VERSION"
	export SELENIUM_PKG_DESCRIPTION="$TERMUX_PKG_DESCRIPTION"
	pip3 install . --prefix $TERMUX_PREFIX
	unset SELENIUM_PKG_VERSION SELENIUM_PKG_DESCRIPTION
}
