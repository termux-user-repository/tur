TERMUX_PKG_HOMEPAGE=https://zaz.sourceforge.net
TERMUX_PKG_DESCRIPTION="Zaz is a game where the player has to get rid of incoming balls by arranging them in triplets."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SRCURL="http://sourceforge.net/projects/zaz/files/zaz-${TERMUX_PKG_VERSION}.tar.bz2/download"
TERMUX_PKG_SHA256=e332cc1a6559e18a2b632940c53d20e2f2d2b583ba9dc1fd02a586437f9f0397
TERMUX_PKG_DEPENDS="sdl, libtheora, sdl-image, libftgl2"
TERMUX_PKG_GROUPS="games"

termux_step_pre_configure() {
	export LDFLAGS+=" -lvorbis"
}