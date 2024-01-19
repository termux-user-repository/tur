TERMUX_PKG_HOMEPAGE=https://tass64.sourceforge.net/
TERMUX_PKG_DESCRIPTION="Cross (turbo) assembler targeting the MOS 65xx series of micro processors"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE-GPL-2.0, LICENSE-LGPL-2.0, LICENSE-LGPL-2.1, LICENSE-my_getopt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.59.3120"
TERMUX_PKG_SRCURL=https://github.com/irmen/64tass/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=ca1ab3b46288963048e254aed97ae3a4ae1a82d74af77bf669f8e3fba754bd25
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	make CC="$CC" CFLAGS="$CFLAGS $CPPFLAGS" LDFLAGS="$LDFLAGS" SVNVERSION="echo ${TERMUX_PKG_VERSION##*.}"
}

termux_step_make_install() {
	make install prefix="$PREFIX"	
}
