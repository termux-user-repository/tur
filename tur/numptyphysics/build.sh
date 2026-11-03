TERMUX_PKG_HOMEPAGE=https://gitlab.com/thp/numptyphysics
TERMUX_PKG_DESCRIPTION="A drawing physics puzzle game in the spirit of Crayon Physics"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="IntinteDAO"
TERMUX_PKG_VERSION=0.3.10
TERMUX_PKG_SRCURL=https://gitlab.com/thp/numptyphysics/-/archive/${TERMUX_PKG_VERSION}/numptyphysics-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=f863ba1bae51934bef31984e40ce1b3dbd82672c0bcd705b50185dd40c4f3618
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="glib, libtinyxml2, sdl2 | sdl2-compat, sdl2-image, sdl2-ttf"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_MAKE_ARGS="PREFIX=$TERMUX_PREFIX"
TERMUX_PKG_GROUPS="games"
