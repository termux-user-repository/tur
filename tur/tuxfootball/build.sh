TERMUX_PKG_HOMEPAGE=http://tuxfootball.sourceforge.net/
TERMUX_PKG_DESCRIPTION="A 2D football game reminiscent of Sensible Soccer and Kick Off"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=0.3.1
TERMUX_PKG_SRCURL=http://sourceforge.net/projects/tuxfootball/files/${TERMUX_PKG_VERSION%.*}/tuxfootball-${TERMUX_PKG_VERSION}.tar.gz/download
TERMUX_PKG_SHA256=44056c15572c2a3f0e3794719961915af15fef5f05596d2ef3f9e247f8a1f3e5
TERMUX_PKG_DEPENDS="gettext, libiconv, sdl, sdl-image, sdl-mixer"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_GROUPS="games"

termux_step_pre_configure() {
	LDFLAGS+=" -liconv"
}
