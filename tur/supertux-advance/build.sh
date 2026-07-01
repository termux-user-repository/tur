TERMUX_PKG_HOMEPAGE=https://github.com/KelvinShadewing/supertux-advance
TERMUX_PKG_DESCRIPTION="A fan game of SuperTux written in Squirrel"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=2026.03.15
TERMUX_PKG_SRCURL=git+https://github.com/KelvinShadewing/supertux-advance.git
TERMUX_PKG_GIT_BRANCH=main
TERMUX_PKG_DEPENDS="brux"

TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
	local INSTALL_DIR=$TERMUX_PREFIX/share/supertux-advance
	mkdir -p $INSTALL_DIR
	cp -a $TERMUX_PKG_SRCDIR/* $INSTALL_DIR/

	mkdir -p $TERMUX_PREFIX/bin
	cat > $TERMUX_PREFIX/bin/supertux-advance <<- EOF
		#!$TERMUX_PREFIX/bin/sh
		cd $INSTALL_DIR
		exec brux game.brx "\$@"
	EOF
	chmod +x $TERMUX_PREFIX/bin/supertux-advance
}
