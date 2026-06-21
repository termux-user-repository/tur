TERMUX_PKG_HOMEPAGE=https://github.com/Natarizki/glyph
TERMUX_PKG_DESCRIPTION="Pure C ASCII art generator with custom fonts, true color styles, and image-to-ASCII conversion"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="Natarizki <natakeren890@gmail.com>"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SRCURL=https://github.com/Natarizki/glyph/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=85134fce77e16fecc204852070fd8004a066bf04fcab1d38e77ec7327f62f8a0
TERMUX_PKG_DEPENDS=""
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
	make install PREFIX=$TERMUX_PREFIX
}
