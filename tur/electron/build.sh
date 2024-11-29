TERMUX_PKG_HOMEPAGE=https://github.com/electron/electron
TERMUX_PKG_DESCRIPTION="A metapackage that provides electron"
TERMUX_PKG_LICENSE="Public Domain"
TERMUX_PKG_MAINTAINER="Chongyun Lee <uchkks@protonmail.com>"
TERMUX_PKG_VERSION=26
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_METAPACKAGE=true

termux_step_make_install() {
	ln -sf $TERMUX_PREFIX/lib/electron$TERMUX_PKG_VERSION $TERMUX_PREFIX/lib/electron
	ln -sf $TERMUX_PREFIX/lib/electron$TERMUX_PKG_VERSION/electron $TERMUX_PREFIX/bin/electron

	TERMUX_PKG_DEPENDS="electron$TERMUX_PKG_VERSION"
}
