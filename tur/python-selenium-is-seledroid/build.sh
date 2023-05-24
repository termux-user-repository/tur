TERMUX_PKG_HOMEPAGE=https://github.com/nacho00112/tur
TERMUX_PKG_DESCRIPTION="A browser automation framework and ecosystem. This dummy selenium uses seledroid as his backend."
TERMUX_PKG_SKIP_SRC_EXTRACT=true
# seledroid is unlicensed, the original selenium is Apache-2.0
TERMUX_PKG_LICENSE="Unlicense"
TERMUX_PKG_MAINTAINER="@nacho00112"
TERMUX_PKG_VERSION=4.8.2
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="python, python-seledroid"

termux_step_make_install() {
	SELENIUM_BUILDDIR="$TERMUX_PKG_TMPDIR/$TERMUX_PKG_NAME"_files
	export SELENIUM_PKG_VERSION=$TERMUX_PKG_VERSION
	export SELENIUM_PKG_DESCRIPTION=$TERMUX_PKG_DESCRIPTION
	export SELENIUM_BUILDDIR="$TERMUX_PKG_TMPDIR/$TERMUX_PKG_NAME"_files
	mkdir -p $SELENIUM_BUILDDIR
	cp $TERMUX_PKG_BUILDER_DIR/setup.py $TERMUX_PKG_BUILDER_DIR/selenium.py $SELENIUM_BUILDDIR
	pip3 install $SELENIUM_BUILDDIR --prefix $TERMUX_PREFIX
	unset SELENIUM_PKG_VERSION SELENIUM_PKG_DESCRIPTION
}
