TERMUX_PKG_HOMEPAGE=https://www.nongnu.org/clanbomber
TERMUX_PKG_DESCRIPTION="The goal of ClanBomber is to blow away your opponents using bombs, but avoid being blown up yourself."
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="\
COPYING
LICENSE.DEJAVU"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.3
TERMUX_PKG_SRCURL=https://github.com/viti95/ClanBomber2/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=ee9ff4c7f49b533d8cf62004434a62bfb8fa43892dfc1cb4f156399dca81c7b1
TERMUX_PKG_DEPENDS="boost, sdl2, sdl2-image, sdl2-mixer, sdl2-ttf"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--with-boost-libdir=${TERMUX_PREFIX}/lib"

termux_step_pre_configure() {
	autoreconf -fvi
}
