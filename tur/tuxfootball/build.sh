TERMUX_PKG_HOMEPAGE=https://tuxfootball.sourceforge.net/
TERMUX_PKG_DESCRIPTION="A 2D football game reminiscent of Sensible Soccer and Kick Off"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=0.3.1
TERMUX_PKG_SRCURL="https://downloads.sourceforge.net/tuxfootball/tuxfootball-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=44056c15572c2a3f0e3794719961915af15fef5f05596d2ef3f9e247f8a1f3e5
TERMUX_PKG_DEPENDS="gettext, libiconv, sdl, sdl-image, sdl-mixer, tuxfootball-data"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_RM_AFTER_INSTALL="doc"

termux_step_pre_configure() {
	LDFLAGS+=" -liconv"
}

termux_step_post_make_install() {
	install -Dm644 -T $TERMUX_PKG_SRCDIR/tuxfootball.png \
		$TERMUX_PREFIX/share/pixmaps/tuxfootball.png
}
