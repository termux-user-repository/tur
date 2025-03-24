TERMUX_PKG_HOMEPAGE="https://qqwing.com/"
TERMUX_PKG_DESCRIPTION="QQwing is software for generating and solving Sudoku puzzles"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.3.7
TERMUX_PKG_SRCURL=https://qqwing.com/qqwing-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=1753736C31FEEA0085F5CFAC33143743204F8A7E66B81CCD17E249ECAFBA802F
TERMUX_PKG_DEPENDS="glib"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_pre_configure(){
	autoreconf -vf
}

termux_step_make(){
	make -j $TERMUX_PKG_MAKE_PROCESSES
}

termux_step_make_install(){
	make install
}
