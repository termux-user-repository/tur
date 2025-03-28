TERMUX_PKG_HOMEPAGE="https://qqwing.com/"
TERMUX_PKG_DESCRIPTION="QQwing is software for generating and solving Sudoku puzzles"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.3.4
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://qqwing.com/qqwing-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=1753736c31feea0085f5cfac33143743204f8a7e66b81ccd17e249ecafba802f
TERMUX_PKG_DEPENDS="glib"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure(){
	autoreconf -vf

	if [ "$TERMUX_ARCH" = arm ]; then
		local _libgcc_file="$($CC -print-libgcc-file-name)"
		local _libgcc_path="$(dirname $_libgcc_file)"
		local _libgcc_name="$(basename $_libgcc_file)"
		LDFLAGS+=" -L$_libgcc_path -l:$_libgcc_name"
	fi
}

termux_step_make(){
	make -j $TERMUX_PKG_MAKE_PROCESSES
}

termux_step_make_install(){
	make install
}
